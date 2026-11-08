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

    public function show(Request $request, int $material): JsonResponse
    {
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

    public function complete(Request $request, int $material): JsonResponse
    {
        $materialData = $this->findPublishedMaterial($material);

        $userId = $request->user()->id;
        $now = now();

        DB::table('user_material_progress')->upsert(
            [[
                'user_id' => $userId,
                'material_id' => $materialData->id,
                'is_completed' => true,
                'completed_at' => $now,
                'created_at' => $now,
                'updated_at' => $now,
            ]],
            ['user_id', 'material_id'],
            ['is_completed', 'updated_at']
        );

        $progress = DB::table('user_material_progress')
            ->where('user_id', $userId)
            ->where('material_id', $materialData->id)
            ->first();

        return response()->json([
            'message' => 'Materi berhasil ditandai selesai',
            'data' => [
                'material_id' => $materialData->id,
                'is_completed' => (bool) $progress->is_completed,
                'completed_at' => $progress->completed_at,
            ],
        ]);
    }
}
