<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Material;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;

class MaterialController extends Controller
{
    public function index(): JsonResponse
    {
        $materials = $this->publishedMaterials()
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'message' => 'Daftar materi berhasil diambil',
            'data' => $materials,
        ]);
    }

    public function bySubject(int $subject): JsonResponse
    {
        $subjectData = Subject::query()
            ->where('is_active', true)
            ->whereHas('category', function ($query) {
                $query->where('is_active', true);
            })
            ->findOrFail($subject);

        $materials = $this->publishedMaterials()
            ->where('subject_id', $subjectData->id)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'message' => 'Daftar materi bidang berhasil diambil',
            'subject' => $subjectData,
            'data' => $materials,
        ]);
    }

    public function show(int $material): JsonResponse
    {
        $materialData = Material::query()
            ->where('is_published', true)
            ->whereHas('subject', function ($query) {
                $query->where('is_active', true)
                    ->whereHas('category', function ($query) {
                        $query->where('is_active', true);
                    });
            })
            ->with('subject.category')
            ->findOrFail($material);

        return response()->json([
            'message' => 'Detail materi berhasil diambil',
            'data' => $materialData,
        ]);
    }

    private function publishedMaterials()
    {
        return Material::query()
            ->select([
                'id',
                'subject_id',
                'title',
                'slug',
                'summary',
                'sort_order',
                'published_at',
            ])
            ->where('is_published', true)
            ->whereHas('subject', function ($query) {
                $query->where('is_active', true)
                    ->whereHas('category', function ($query) {
                        $query->where('is_active', true);
                    });
            });
    }
}
