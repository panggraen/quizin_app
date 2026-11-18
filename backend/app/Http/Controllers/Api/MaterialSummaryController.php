<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MaterialSummaryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        // Hanya kategori aktif, bidang aktif,
        // dan materi yang sudah dipublikasikan.
        $categories = DB::table('categories as c')
            ->leftJoin('subjects as s', function ($join) {
                $join->on('s.category_id', '=', 'c.id')
                    ->where('s.is_active', true);
            })
            ->leftJoin('materials as m', function ($join) {
                $join->on('m.subject_id', '=', 's.id')
                    ->where('m.is_published', true);
            })
            ->leftJoin('user_material_progress as p', function ($join) use ($userId) {
                $join->on('p.material_id', '=', 'm.id')
                    ->where('p.user_id', '=', $userId);
            })
            ->where('c.is_active', true)
            ->select(
                'c.id',
                'c.name',
                'c.slug',
                'c.sort_order'
            )
            ->selectRaw('COUNT(m.id) as total_materials')
            ->selectRaw(
                'SUM(CASE WHEN p.is_completed = 1 THEN 1 ELSE 0 END) as completed_materials'
            )
            ->groupBy(
                'c.id',
                'c.name',
                'c.slug',
                'c.sort_order'
            )
            ->orderBy('c.sort_order')
            ->orderBy('c.id')
            ->get();

        $total = 0;
        $completed = 0;

        $categoryProgress = $categories->map(function ($category) use (
            &$total,
            &$completed
        ) {
            $categoryTotal = (int) $category->total_materials;
            $categoryCompleted = (int) $category->completed_materials;

            $total += $categoryTotal;
            $completed += $categoryCompleted;

            return [
                'category_id' => $category->id,
                'name' => $category->name,
                'slug' => $category->slug,
                'total_materials' => $categoryTotal,
                'completed_materials' => $categoryCompleted,
                'progress_percentage' => $categoryTotal > 0
                    ? round($categoryCompleted / $categoryTotal * 100, 2)
                    : 0,
            ];
        });

        return response()->json([
            'message' => 'Ringkasan progres materi berhasil diambil.',
            'data' => [
                'total_materials' => $total,
                'completed_materials' => $completed,
                'remaining_materials' => $total - $completed,
                'progress_percentage' => $total > 0
                    ? round($completed / $total * 100, 2)
                    : 0,
                'categories' => $categoryProgress,
            ],
        ]);
    }
}
