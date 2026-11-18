<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizResultController extends Controller
{
    private function completedAttempt(int $attempt, int $userId)
    {
        return DB::table('quiz_attempts as a')
            ->join('quiz_modules as m', 'm.id', '=', 'a.quiz_module_id')
            ->where('a.id', $attempt)
            ->where('a.user_id', $userId)
            ->select(
                'a.*',
                'm.title as module_title',
                'm.module_number'
            )
            ->first();
    }

    public function result(Request $request, int $attempt): JsonResponse
    {
        $session = $this->completedAttempt(
            $attempt,
            $request->user()->id
        );

        if (!$session) {
            return response()->json([
                'message' => 'Sesi kuis tidak ditemukan.',
            ], 404);
        }

        if ($session->status !== 'completed') {
            return response()->json([
                'message' => 'Kuis belum diselesaikan.',
            ], 409);
        }

        $progress = DB::table('user_module_progress')
            ->where('user_id', $request->user()->id)
            ->where('quiz_module_id', $session->quiz_module_id)
            ->first();

        $isFirstCompletion = $progress
            && (int) $progress->first_completed_attempt_id
                === (int) $session->id;

        return response()->json([
            'message' => 'Hasil kuis berhasil diambil.',
            'data' => [
                'attempt_id' => $session->id,
                'module' => [
                    'id' => $session->quiz_module_id,
                    'title' => $session->module_title,
                    'module_number' => (int) $session->module_number,
                ],
                'status' => $session->status,
                'score' => (int) $session->score,
                'correct_answers' => (int) $session->correct_answers,
                'total_questions' => (int) $session->total_questions,
                'incorrect_answers' =>
                    (int) $session->total_questions
                    - (int) $session->correct_answers,
                'completed_at' => $session->completed_at,
                'is_first_completion' => (bool) $isFirstCompletion,
                'xp_awarded' => $isFirstCompletion
                    ? (int) $progress->xp_awarded
                    : 0,
                'coins_awarded' => $isFirstCompletion
                    ? (int) $progress->coins_awarded
                    : 0,
                'best_score' => $progress?->best_score !== null
                    ? (int) $progress->best_score
                    : null,
            ],
        ]);
    }

    public function review(Request $request, int $attempt): JsonResponse
    {
        $session = $this->completedAttempt(
            $attempt,
            $request->user()->id
        );

        if (!$session) {
            return response()->json([
                'message' => 'Sesi kuis tidak ditemukan.',
            ], 404);
        }

        if ($session->status !== 'completed') {
            return response()->json([
                'message' => 'Pembahasan tersedia setelah kuis selesai.',
            ], 409);
        }

        $answers = DB::table('quiz_attempt_answers as a')
            ->join('questions as q', 'q.id', '=', 'a.question_id')
            ->join(
                'question_options as selected',
                'selected.id',
                '=',
                'a.question_option_id'
            )
            ->where('a.quiz_attempt_id', $session->id)
            ->where('q.quiz_module_id', $session->quiz_module_id)
            ->select(
                'q.id as question_id',
                'q.sort_order',
                'q.question_text',
                'q.explanation',
                'a.is_correct',
                'selected.id as selected_option_id',
                'selected.option_label as selected_label',
                'selected.option_text as selected_text'
            )
            ->orderBy('q.sort_order')
            ->orderBy('q.id')
            ->get();

        $correctOptions = DB::table('question_options')
            ->whereIn('question_id', $answers->pluck('question_id'))
            ->where('is_correct', true)
            ->get()
            ->keyBy('question_id');

        $review = $answers->map(function ($answer) use ($correctOptions) {
            $correct = $correctOptions->get($answer->question_id);

            return [
                'question_id' => $answer->question_id,
                'question_number' => (int) $answer->sort_order,
                'question_text' => $answer->question_text,
                'is_correct' => (bool) $answer->is_correct,
                'selected_option' => [
                    'id' => $answer->selected_option_id,
                    'label' => $answer->selected_label,
                    'text' => $answer->selected_text,
                ],
                'correct_option' => $correct ? [
                    'id' => $correct->id,
                    'label' => $correct->option_label,
                    'text' => $correct->option_text,
                ] : null,
                'explanation' => $answer->explanation,
            ];
        });

        return response()->json([
            'message' => 'Pembahasan kuis berhasil diambil.',
            'data' => [
                'attempt_id' => $session->id,
                'module_title' => $session->module_title,
                'score' => (int) $session->score,
                'total_questions' => (int) $session->total_questions,
                'questions' => $review,
            ],
        ]);
    }
}
