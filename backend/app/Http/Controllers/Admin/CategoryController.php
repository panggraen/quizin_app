<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class CategoryController extends Controller
{
    public function index(): View
    {
        $categories = DB::table('categories')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        // Hitung jumlah bidang untuk setiap kategori.
        $subjectCounts = DB::table('subjects')
            ->select('category_id')
            ->selectRaw('COUNT(*) as total')
            ->groupBy('category_id')
            ->pluck('total', 'category_id');

        foreach ($categories as $category) {
            $category->subjects_count = (int) (
                $subjectCounts[$category->id] ?? 0
            );
        }

        return view('admin.categories.index', [
            'categories' => $categories,
        ]);
    }
}
