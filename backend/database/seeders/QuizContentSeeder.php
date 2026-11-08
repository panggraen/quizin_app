<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class QuizContentSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        // Kategori utama QUIZIN
        $categories = [
            ['name' => 'Science', 'slug' => 'science', 'sort_order' => 1],
            ['name' => 'History', 'slug' => 'history', 'sort_order' => 2],
            ['name' => 'Mathematics', 'slug' => 'mathematics', 'sort_order' => 3],
        ];

        foreach ($categories as $category) {
            DB::table('categories')->insertOrIgnore([
                ...$category,
                'is_active' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }

        // Mengambil ID kategori Science
        $scienceId = DB::table('categories')
            ->where('slug', 'science')
            ->value('id');

        // Bidang awal Science
        $subjects = [
            ['name' => 'Biologi', 'slug' => 'biologi', 'sort_order' => 1],
            ['name' => 'Fisika', 'slug' => 'fisika', 'sort_order' => 2],
            ['name' => 'Kimia', 'slug' => 'kimia', 'sort_order' => 3],
        ];

        foreach ($subjects as $subject) {
            DB::table('subjects')->insertOrIgnore([
                ...$subject,
                'category_id' => $scienceId,
                'is_active' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }

        // Mengambil ID bidang Biologi
        $biologyId = DB::table('subjects')
            ->where('category_id', $scienceId)
            ->where('slug', 'biologi')
            ->value('id');

        // Contoh materi untuk pengujian API
        DB::table('materials')->insertOrIgnore([
            'subject_id' => $biologyId,
            'title' => 'Pengenalan Sel',
            'slug' => 'pengenalan-sel',
            'summary' => 'Mengenal sel sebagai unit dasar kehidupan.',
            'content' => "Sel adalah unit struktural dan fungsional terkecil penyusun makhluk hidup.\n\nSecara umum, sel memiliki membran sel, sitoplasma, dan materi genetik.\n\nSel prokariotik tidak memiliki inti bermembran, sedangkan sel eukariotik memiliki inti bermembran.",
            'sort_order' => 1,
            'is_published' => true,
            'published_at' => $now,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }
}
