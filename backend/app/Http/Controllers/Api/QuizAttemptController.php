<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizAttemptController extends Controller
{
    public function start(Request $request, int $module): JsonResponse
    {
        $userId = $request->user()->id;

        // Pastikan modul dan konten pembelajaran aktif.
        $quizModule = DB::table('quiz_modules as qm')
            ->join('materials as m', 'm.id', '=', 'qm.material_id')
            ->join('subjects as s', 's.id', '=', 'm.subject_id')
            ->join('categories as c', 'c.id', '=', 's.category_id')
            ->where('qm.id', $module)
            ->where('qm.is_published', true)
            ->where('m.is_published', true)
            ->where('s.is_active', true)
            ->where('c.is_active', true)
            ->select(
                'qm.id',
                'qm.material_id',
                'qm.title',
                'qm.module_number'
            )
            ->first();

        if (!$quizModule) {
            return response()->json([
                'message' => 'Modul kuis tidak ditemukan.',
            ], 404);
        }

        // Ambil modul terpublikasi sebelumnya.
        $previousModule = DB::table('quiz_modules')
            ->where('material_id', $quizModule->material_id)
            ->where('is_published', true)
            ->where('module_number', '<', $quizModule->module_number)
            ->orderByDesc('module_number')
            ->first();

        $questions = DB::table('questions')
            ->where('quiz_module_id', $quizModule->id)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        if ($questions->isEmpty()) {
            return response()->json([
                'message' => 'Modul ini belum memiliki soal.',
            ], 409);
        }

        // Validasi kelengkapan pilihan dan kunci jawaban.
        $options = DB::table('question_options')
            ->whereIn('question_id', $questions->pluck('id'))
            ->orderBy('option_label')
            ->get()
            ->groupBy('question_id');

        foreach ($questions as $question) {
            $questionOptions = $options->get($question->id, collect());

            if (
                $questionOptions->count() !== 4 ||
                $questionOptions->where('is_correct', true)->count() !== 1
            ) {
                return response()->json([
                    'message' => 'Pilihan jawaban pada modul belum lengkap.',
                ], 409);
            }
        }

        return DB::transaction(function () use (
            $userId,
            $quizModule,
            $previousModule,
            $questions,
            $options
        ) {
            // Menghindari pembuatan dua sesi secara bersamaan
            // oleh akun yang sama.
            DB::table('users')
                ->where('id', $userId)
                ->lockForUpdate()
                ->first();

            // Modul berikutnya harus menunggu
            // penyelesaian modul sebelumnya.
            if ($previousModule) {
                $isPreviousCompleted = DB::table('user_module_progress')
                    ->where('user_id', $userId)
                    ->where('quiz_module_id', $previousModule->id)
                    ->whereNotNull('first_completed_at')
                    ->exists();

                if (!$isPreviousCompleted) {
                    return response()->json([
                        'message' => 'Selesaikan modul sebelumnya terlebih dahulu.',
                    ], 403);
                }
            }

            // Cari sesi yang masih berlangsung.
            $attempt = DB::table('quiz_attempts')
                ->where('user_id', $userId)
                ->where('quiz_module_id', $quizModule->id)
                ->where('status', 'in_progress')
                ->orderByDesc('id')
                ->first();

            $isResumed = $attempt !== null;

            // Jika belum ada sesi, buat sesi baru.
            if (!$attempt) {
                $now = now();

                $attemptId = DB::table('quiz_attempts')->insertGetId([
                    'user_id' => $userId,
                    'quiz_module_id' => $quizModule->id,
                    'status' => 'in_progress',
                    'total_questions' => $questions->count(),
                    'correct_answers' => 0,
                    'score' => null,
                    'started_at' => $now,
                    'completed_at' => null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);

                $attempt = DB::table('quiz_attempts')
                    ->where('id', $attemptId)
                    ->first();
            }

            // Ambil jawaban yang sudah tersimpan
            // apabila pengguna melanjutkan sesi.
            $savedAnswers = DB::table('quiz_attempt_answers')
                ->where('quiz_attempt_id', $attempt->id)
                ->get()
                ->keyBy('question_id');

            // Siapkan soal tanpa kunci jawaban.
            $questionData = $questions->map(function ($question) use (
                $options,
                $savedAnswers
            ) {
                $saved = $savedAnswers->get($question->id);

                return [
                    'id' => $question->id,
                    'question_number' => (int) $question->sort_order,
                    'question_text' => $question->question_text,
                    'selected_option_id' => $saved?->question_option_id,
                    'options' => $options->get(
                        $question->id,
                        collect()
                    )->map(function ($option) {
                        return [
                            'id' => $option->id,
                            'label' => $option->option_label,
                            'text' => $option->option_text,
                        ];
                    })->values(),
                ];
            });

            return response()->json([
                'message' => $isResumed
                    ? 'Sesi kuis sebelumnya berhasil dilanjutkan.'
                    : 'Sesi kuis berhasil dimulai.',
                'data' => [
                    'attempt_id' => $attempt->id,
                    'status' => $attempt->status,
                    'is_resumed' => $isResumed,
                    'module' => [
                        'id' => $quizModule->id,
                        'title' => $quizModule->title,
                        'module_number' => (int) $quizModule->module_number,
                    ],
                    'total_questions' => (int) $attempt->total_questions,
                    'answered_count' => $savedAnswers->count(),
                    'questions' => $questionData,
                ],
            ]);
        }, 3);
    }
    
public function abandon(Request $request, int $attempt): JsonResponse
{
    $userId = $request->user()->id;

    return DB::transaction(function () use ($attempt, $userId) {

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

        if ($session->status === 'completed') {
            return response()->json([
                'message' => 'Kuis yang sudah selesai tidak dapat dibatalkan.',
            ], 409);
        }

        if ($session->status === 'abandoned') {
            return response()->json([
                'message' => 'Sesi kuis sudah dibatalkan.',
                'data' => [
                    'attempt_id' => $session->id,
                    'status' => 'abandoned',
                ],
            ]);
        }

        DB::table('quiz_attempts')
            ->where('id', $session->id)
            ->update([
                'status' => 'abandoned',
                'updated_at' => now(),
            ]);

        return response()->json([
            'message' => 'Pengerjaan kuis berhasil dibatalkan.',
            'data' => [
                'attempt_id' => $session->id,
                'status' => 'abandoned',
                'xp_awarded' => 0,
                'coins_awarded' => 0,
            ],
        ]);

    }, 3);
}

}
