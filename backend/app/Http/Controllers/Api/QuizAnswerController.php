<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\BadgeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizAnswerController extends Controller
{
    // Sesuaikan dengan enum coin_transactions.type.
    private const COIN_EARN_TYPE = 'quiz_reward';

    public function store(Request $request, int $attempt): JsonResponse
    {
        $validated = $request->validate([
            'question_id' => ['required', 'integer', 'min:1'],
            'question_option_id' => ['required', 'integer', 'min:1'],
        ]);

        $userId = $request->user()->id;

        return DB::transaction(function () use (
            $attempt,
            $userId,
            $validated
        ) {
            $session = DB::table('quiz_attempts')
                ->where('id', $attempt)
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->first();

            if (!$session) {
                return response()->json([
                    'message' => 'Sesi kuis tidak ditemukan.',
                ], 404);
            }

            if ($session->status !== 'in_progress') {
                return response()->json([
                    'message' => 'Sesi kuis sudah tidak aktif.',
                ], 409);
            }

            $question = DB::table('questions')
                ->where('id', $validated['question_id'])
                ->where('quiz_module_id', $session->quiz_module_id)
                ->first();

            if (!$question) {
                return response()->json([
                    'message' => 'Soal tidak ditemukan dalam sesi ini.',
                ], 422);
            }

            $option = DB::table('question_options')
                ->where('id', $validated['question_option_id'])
                ->where('question_id', $question->id)
                ->first();

            if (!$option) {
                return response()->json([
                    'message' => 'Pilihan jawaban tidak valid.',
                ], 422);
            }

            // Setiap soal hanya boleh dijawab satu kali
            // dalam satu sesi pengerjaan.
            $alreadyAnswered = DB::table('quiz_attempt_answers')
                ->where('quiz_attempt_id', $session->id)
                ->where('question_id', $question->id)
                ->exists();

            if ($alreadyAnswered) {
                return response()->json([
                    'message' => 'Soal ini sudah dijawab.',
                ], 409);
            }

            // Cegah penyelesaian menggunakan jumlah soal
            // yang sudah berubah sejak sesi dimulai.
            $currentQuestionCount = DB::table('questions')
                ->where('quiz_module_id', $session->quiz_module_id)
                ->count();

            if ($currentQuestionCount !== (int) $session->total_questions) {
                return response()->json([
                    'message' => 'Konten kuis berubah. Sesi perlu ditinjau.',
                ], 409);
            }

            $correctOption = DB::table('question_options')
                ->where('question_id', $question->id)
                ->where('is_correct', true)
                ->first();

            if (!$correctOption) {
                return response()->json([
                    'message' => 'Kunci jawaban belum tersedia.',
                ], 409);
            }

            $now = now();
            $isCorrect = (bool) $option->is_correct;

            // Simpan jawaban pengguna.
            DB::table('quiz_attempt_answers')->insert([
                'quiz_attempt_id' => $session->id,
                'question_id' => $question->id,
                'question_option_id' => $option->id,
                'is_correct' => $isCorrect,
                'answered_at' => $now,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $answers = DB::table('quiz_attempt_answers')
                ->where('quiz_attempt_id', $session->id);

            $answeredCount = (clone $answers)->count();

            $correctCount = (clone $answers)
                ->where('is_correct', true)
                ->count();

            $totalQuestions = (int) $session->total_questions;
            $isCompleted = $answeredCount === $totalQuestions;

            $completion = null;

            // Proses hanya dijalankan jika seluruh soal selesai.
            if ($isCompleted) {

                $score = (int) round(
                    $correctCount / $totalQuestions * 100
                );

                $stats = DB::table('user_stats')
                    ->where('user_id', $userId)
                    ->lockForUpdate()
                    ->first();

                if (!$stats) {
                    // Exception akan membatalkan transaksi.
                    throw new \RuntimeException(
                        'Statistik pengguna tidak ditemukan.'
                    );
                }

                $progress = DB::table('user_module_progress')
                    ->where('user_id', $userId)
                    ->where('quiz_module_id', $session->quiz_module_id)
                    ->lockForUpdate()
                    ->first();

                // Hadiah hanya diberikan pada penyelesaian
                // pertama untuk setiap modul kuis.
                $firstCompletion = !$progress ||
                    $progress->first_completed_at === null;

                $xpAwarded = $firstCompletion
                    ? $correctCount * 10
                    : 0;

                $coinsAwarded = $firstCompletion
                    ? $correctCount
                    : 0;

                $newTotalXp = (int) $stats->total_xp + $xpAwarded;
                $newCoinBalance = (int) $stats->coin_balance + $coinsAwarded;
                $newLevel = intdiv($newTotalXp, 100) + 1;

                // 1. Selesaikan sesi kuis.
                DB::table('quiz_attempts')
                    ->where('id', $session->id)
                    ->update([
                        'status' => 'completed',
                        'correct_answers' => $correctCount,
                        'score' => $score,
                        'completed_at' => $now,
                        'updated_at' => $now,
                    ]);

                // 2. Berikan XP dan koin jika ini
                // penyelesaian modul pertama kali.
                if ($firstCompletion) {

                    DB::table('user_stats')
                        ->where('id', $stats->id)
                        ->update([
                            'total_xp' => $newTotalXp,
                            'level' => $newLevel,
                            'coin_balance' => $newCoinBalance,
                            'updated_at' => $now,
                        ]);

                    // Catat hadiah koin untuk audit.
                    if ($coinsAwarded > 0) {
                        DB::table('coin_transactions')->insert([
                            'user_id' => $userId,
                            'type' => self::COIN_EARN_TYPE,
                            'amount' => $coinsAwarded,
                            'balance_after' => $newCoinBalance,
                            'quiz_attempt_id' => $session->id,
                            'character_id' => null,
                            'description' => 'Hadiah menyelesaikan modul kuis',
                            'created_at' => $now,
                            'updated_at' => $now,
                        ]);
                    }
                }

                // 3. Perbarui skor terbaik dan
                // jumlah percobaan modul.
                $bestScore = max(
                    (int) ($progress?->best_score ?? 0),
                    $score
                );

                $attemptCount = (int) (
                    $progress?->attempt_count ?? 0
                ) + 1;

                if (!$progress) {

                    DB::table('user_module_progress')->insert([
                        'user_id' => $userId,
                        'quiz_module_id' => $session->quiz_module_id,
                        'first_completed_attempt_id' => $session->id,
                        'best_score' => $bestScore,
                        'attempt_count' => $attemptCount,
                        'first_completed_at' => $now,
                        'last_completed_at' => $now,
                        'xp_awarded' => $xpAwarded,
                        'coins_awarded' => $coinsAwarded,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ]);

                } else {

                    $updates = [
                        'best_score' => $bestScore,
                        'attempt_count' => $attemptCount,
                        'last_completed_at' => $now,
                        'updated_at' => $now,
                    ];

                    if ($firstCompletion) {
                        $updates['first_completed_attempt_id'] = $session->id;
                        $updates['first_completed_at'] = $now;
                        $updates['xp_awarded'] = $xpAwarded;
                        $updates['coins_awarded'] = $coinsAwarded;
                    }

                    DB::table('user_module_progress')
                        ->where('id', $progress->id)
                        ->update($updates);
                }

                // 4. PEMBERIAN BADGE OTOMATIS
                // Dijalankan setelah progres modul tersimpan.
                // Badge tidak memberikan tambahan XP/koin.
                $newBadges = [];

                if ($firstCompletion) {
                    $newBadges = app(BadgeService::class)
                        ->awardEligibleBadges($userId);
                }

                // 5. Siapkan ringkasan hasil kuis.
                $completion = [
                    'score' => $score,
                    'correct_answers' => $correctCount,
                    'total_questions' => $totalQuestions,
                    'first_completion' => $firstCompletion,
                    'xp_awarded' => $xpAwarded,
                    'coins_awarded' => $coinsAwarded,
                    'total_xp' => $newTotalXp,
                    'coin_balance' => $newCoinBalance,
                    'level' => $newLevel,
                    'best_score' => $bestScore,
                    'attempt_count' => $attemptCount,
                    'new_badges' => $newBadges,
                ];
            }

            // Respons untuk Flutter.
            return response()->json([
                'message' => $isCompleted
                    ? 'Kuis berhasil diselesaikan.'
                    : 'Jawaban berhasil disimpan.',
                'data' => [
                    'attempt_id' => $session->id,
                    'question_id' => $question->id,
                    'selected_option_id' => $option->id,
                    'is_correct' => $isCorrect,
                    'correct_option' => [
                        'id' => $correctOption->id,
                        'label' => $correctOption->option_label,
                        'text' => $correctOption->option_text,
                    ],
                    'explanation' => $question->explanation,
                    'answered_count' => $answeredCount,
                    'total_questions' => $totalQuestions,
                    'is_completed' => $isCompleted,
                    'completion' => $completion,
                ],
            ]);

        }, 3);
    }
}
