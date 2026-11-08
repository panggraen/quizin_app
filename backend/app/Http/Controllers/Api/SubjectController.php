<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;

class SubjectController extends Controller
{
    public function index(int $category): JsonResponse
    {
        $categoryData = Category::query()
            ->where('is_active', true)
            ->findOrFail($category);

        $subjects = Subject::query()
            ->where('category_id', $categoryData->id)
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'message' => 'Daftar bidang berhasil diambil',
            'category' => $categoryData,
            'data' => $subjects,
        ]);
    }
}
