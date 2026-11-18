<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = DB::table('user_stats')
            ->where('user_id', $user->id)
            ->first();

        if (!$stats) {
            return response()->json([
                'message' => 'Statistik pengguna tidak ditemukan.',
            ], 409);
        }

        // Jumlah materi yang diselesaikan.
        $completedMaterials = DB::table('user_material_progress')
            ->where('user_id', $user->id)
            ->where('is_completed', true)
            ->count();

        // Modul unik yang sudah selesai.
        $completedModules = DB::table('user_module_progress')
            ->where('user_id', $user->id)
            ->whereNotNull('first_completed_at')
            ->count();

        // Jumlah sesi kuis selesai, termasuk pengulangan.
        $completedAttempts = DB::table('quiz_attempts')
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();

        // Jumlah badge pengguna.
        $earnedBadges = DB::table('user_badges')
            ->where('user_id', $user->id)
            ->count();

        // Karakter aktif.
        $activeCharacter = null;

        if ($stats->active_character_id !== null) {
            $activeCharacter = DB::table('characters')
                ->where('id', $stats->active_character_id)
                ->select('id', 'name', 'image_path')
                ->first();
        }

        $totalXp = (int) $stats->total_xp;
        $xpInLevel = $totalXp % 100;

        return response()->json([
            'message' => 'Profil pengguna berhasil diambil.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'stats' => [
                    'total_xp' => $totalXp,
                    'level' => (int) $stats->level,
                    'coin_balance' => (int) $stats->coin_balance,
                    'xp_in_current_level' => $xpInLevel,
                    'xp_to_next_level' => 100 - $xpInLevel,
                ],
                'learning_progress' => [
                    'completed_materials' => $completedMaterials,
                    'completed_modules' => $completedModules,
                    'completed_quiz_attempts' => $completedAttempts,
                    'earned_badges' => $earnedBadges,
                ],
                'active_character' => $activeCharacter,
            ],
        ]);
    }

public function update(Request $request): JsonResponse
{
    // Validasi nama pengguna.
    $validated = $request->validate([
        'name' => [
            'required',
            'string',
            'min:2',
            'max:100',
        ],
    ]);

    $user = $request->user();

    // Hanya memperbarui nama, bukan statistik.
    $user->update([
        'name' => $validated['name'],
    ]);

    return response()->json([
        'message' => 'Nama profil berhasil diperbarui.',
        'data' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ],
    ]);
}

}
