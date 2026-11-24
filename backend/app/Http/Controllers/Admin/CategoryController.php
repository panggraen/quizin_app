<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use stdClass;

class CategoryController extends Controller
{
    public function index(): View
    {
        return $this->categoryPage();
    }

    public function create(): View
    {
        return $this->categoryPage(true);
    }

    public function store(Request $request): RedirectResponse
    {
        $category = $this->validatedData($request);
        $category['created_at'] = now();
        $category['updated_at'] = now();

        DB::table('categories')->insert($category);

        return redirect()
            ->route('admin.categories.index')
            ->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function edit(int $category): View
    {
        $editingCategory = DB::table('categories')
            ->where('id', $category)
            ->firstOrFail();

        return $this->categoryPage(true, $editingCategory);
    }

    public function update(Request $request, int $category): RedirectResponse
    {
        $data = $this->validatedData($request, $category);
        $data['updated_at'] = now();

        DB::table('categories')
            ->where('id', $category)
            ->update($data);

        return redirect()
            ->route('admin.categories.index')
            ->with('success', 'Kategori berhasil diperbarui.');
    }

    public function destroy(int $category): RedirectResponse
    {
        DB::table('categories')->where('id', $category)->firstOrFail();

        if (DB::table('subjects')->where('category_id', $category)->exists()) {
            return redirect()
                ->route('admin.categories.index')
                ->with(
                    'error',
                    'Kategori tidak dapat dihapus karena masih memiliki bidang.'
                );
        }

        DB::table('categories')->where('id', $category)->delete();

        return redirect()
            ->route('admin.categories.index')
            ->with('success', 'Kategori berhasil dihapus.');
    }

    private function categoryPage(
        bool $showForm = false,
        ?stdClass $editingCategory = null
    ): View {
        $categories = DB::table('categories')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

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

        return view('admin.categories.index', compact(
            'categories',
            'showForm',
            'editingCategory'
        ));
    }

    private function validatedData(Request $request, ?int $categoryId = null): array
    {
        $slugRule = Rule::unique('categories', 'slug');

        if ($categoryId !== null) {
            $slugRule->ignore($categoryId);
        }

        return $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'slug' => ['required', 'string', 'max:120', 'alpha_dash', $slugRule],
            'description' => ['nullable', 'string'],
            'is_active' => ['required', 'boolean'],
            'sort_order' => ['required', 'integer', 'min:0'],
        ]);
    }
}
