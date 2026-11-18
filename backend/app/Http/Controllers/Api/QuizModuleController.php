<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizModuleController extends Controller
{
    public function index(Request $request, int $material): JsonResponse
    {
        // Pastikan materi dan struktur pembelajarannya
        // sudah tersedia untuk pengguna.
        $materialData = DB::table('materials as m')
            ->join('subjects as s', 's.id', '=', 'm.subject_id')
            ->join('categories as c', 'c.id', '=', 's.category_id')
            ->where('m.id', $material)
            ->where('m.is_published', true)
            ->where('s.is_active', true)
            ->where('c.is_active', true)
            ->select('m.id', 'm.title', 'm.subject_id')
            ->first();

        if (!$materialData) {
            return response()->json([
                'message' => 'Materi tidak ditemukan.',
            ], 404);
        }

        // Ambil modul yang sudah dipublikasikan.
        $modules = DB::table('quiz_modules')
            ->where('material_id', $materialData->id)
            ->where('is_published', true)
            ->orderBy('module_number')
            ->orderBy('id')
            ->get();

        $moduleIds = $modules->pluck('id')->all();

        // Hitung jumlah soal per modul.
        $questionCounts = DB::table('questions')
            ->whereIn('quiz_module_id', $moduleIds)
            ->selectRaw('quiz_module_id, COUNT(*) as total')
            ->groupBy('quiz_module_id')
            ->pluck('total', 'quiz_module_id');

        // Ambil progres modul pengguna yang sedang login.
        $progress = DB::table('user_module_progress')
            ->where('user_id', $request->user()->id)
            ->whereIn('quiz_module_id', $moduleIds)
            ->get()
            ->keyBy('quiz_module_id');

        $previousCompleted = true;

        $result = $modules->map(function ($module) use (
            $questionCounts,
            $progress,
            &$previousCompleted
        ) {
            $userProgress = $progress->get($module->id);

            $isCompleted = $userProgress !== null
                && $userProgress->first_completed_at !== null;

            // Modul pertama terbuka otomatis.
            // Modul berikutnya membutuhkan penyelesaian
            // modul sebelumnya.
            $isUnlocked = $previousCompleted;

            $previousCompleted = $isCompleted;

            return [
                'id' => $module->id,
                'title' => $module->title,
                'description' => $module->description,
                'module_number' => (int) $module->module_number,
                'total_questions' => (int) (
                    $questionCounts[$module->id] ?? 0
                ),
                'is_unlocked' => $isUnlocked,
                'is_completed' => $isCompleted,
                'best_score' => $userProgress?->best_score !== null
                    ? (int) $userProgress->best_score
                    : null,
                'attempt_count' => (int) (
                    $userProgress?->attempt_count ?? 0
                ),
            ];
        });

        return response()->json([
            'message' => 'Daftar modul kuis berhasil diambil.',
            'data' => [
                'material' => [
                    'id' => $materialData->id,
                    'title' => $materialData->title,
                ],
                'modules' => $result,
            ],
        ]);
    }
}
