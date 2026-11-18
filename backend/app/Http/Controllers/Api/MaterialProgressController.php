<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Material;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MaterialProgressController extends Controller
{
    private function findPublishedMaterial(int $material): Material
    {
        return Material::query()
            ->where('is_published', true)
            ->whereHas('subject', function ($query) {
                $query->where('is_active', true)
                    ->whereHas('category', function ($query) {
                        $query->where('is_active', true);
                    });
            })
            ->findOrFail($material);
    }

    public function show(
        Request $request,
        int $material
    ): JsonResponse {
        $materialData = $this->findPublishedMaterial($material);

        $progress = DB::table('user_material_progress')
            ->where('user_id', $request->user()->id)
            ->where('material_id', $materialData->id)
            ->first();

        return response()->json([
            'material_id' => $materialData->id,
            'is_completed' => (bool) ($progress?->is_completed ?? false),
            'completed_at' => $progress?->completed_at,
        ]);
    }

    public function complete(
        Request $request,
        int $material
    ): JsonResponse {
        $materialData = $this->findPublishedMaterial($material);
        $userId = $request->user()->id;

        $result = DB::transaction(function () use (
            $userId,
            $materialData
        ) {
            // Mengunci statistik pengguna selama transaksi.
            // Ini membantu mencegah XP ganda dari request bersamaan.
            $stats = DB::table('user_stats')
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->first();

            if (!$stats) {
                return ['error' => true];
            }

            $progress = DB::table('user_material_progress')
                ->where('user_id', $userId)
                ->where('material_id', $materialData->id)
                ->first();

            // Materi sudah pernah diselesaikan:
            // tidak memberikan XP lagi.
            if ($progress && $progress->is_completed) {
                return [
                    'already_completed' => true,
                    'xp_awarded' => 0,
                    'total_xp' => (int) $stats->total_xp,
                    'level' => (int) $stats->level,
                    'completed_at' => $progress->completed_at,
                ];
            }

            $now = now();

            if ($progress) {
                DB::table('user_material_progress')
                    ->where('user_id', $userId)
                    ->where('material_id', $materialData->id)
                    ->update([
                        'is_completed' => true,
                        'completed_at' => $now,
                        'updated_at' => $now,
                    ]);
            } else {
                DB::table('user_material_progress')->insert([
                    'user_id' => $userId,
                    'material_id' => $materialData->id,
                    'is_completed' => true,
                    'completed_at' => $now,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }

            // Hadiah materi hanya 10 XP, tanpa koin.
            $newTotalXp = (int) $stats->total_xp + 10;
            $newLevel = intdiv($newTotalXp, 100) + 1;

            DB::table('user_stats')
                ->where('user_id', $userId)
                ->update([
                    'total_xp' => $newTotalXp,
                    'level' => $newLevel,
                    'updated_at' => $now,
                ]);

            return [
                'already_completed' => false,
                'xp_awarded' => 10,
                'total_xp' => $newTotalXp,
                'level' => $newLevel,
                'completed_at' => $now,
            ];
        }, 3);

        if (isset($result['error'])) {
            return response()->json([
                'message' => 'Data statistik pengguna tidak ditemukan.',
            ], 409);
        }

        return response()->json([
            'message' => $result['already_completed']
                ? 'Materi sudah pernah diselesaikan.'
                : 'Materi berhasil diselesaikan.',
            'data' => [
                'material_id' => $materialData->id,
                'is_completed' => true,
                ...$result,
            ],
        ]);
    }
}
