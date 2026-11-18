<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class QuizModuleTwoSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $moduleOne = DB::table('quiz_modules')
                ->where('module_number', 1)
                ->where('material_id', 1)
                ->first();

            if (!$moduleOne) {
                throw new RuntimeException(
                    'Modul 1 Pengenalan Sel belum tersedia.'
                );
            }

            $now = now();

            // Membuat Modul 2 untuk materi yang sama.
            DB::table('quiz_modules')->updateOrInsert(
                [
                    'material_id' => $moduleOne->material_id,
                    'module_number' => 2,
                ],
                [
                    'title' => 'Modul 2 - Struktur Sel',
                    'description' => 'Latihan lanjutan mengenai struktur sel.',
                    'is_published' => true,
                    'published_at' => $now,
                    'updated_at' => $now,
                ]
            );

            $moduleTwo = DB::table('quiz_modules')
                ->where('material_id', $moduleOne->material_id)
                ->where('module_number', 2)
                ->first();

            // Satu soal dummy cukup untuk pengujian akses.
            DB::table('questions')->updateOrInsert(
                [
                    'quiz_module_id' => $moduleTwo->id,
                    'sort_order' => 1,
                ],
                [
                    'question_text' =>
                        'Organel manakah yang berfungsi sebagai pusat pengendali sel?',
                    'explanation' =>
                        'Nukleus mengatur berbagai aktivitas sel.',
                    'updated_at' => $now,
                ]
            );

            $question = DB::table('questions')
                ->where('quiz_module_id', $moduleTwo->id)
                ->where('sort_order', 1)
                ->first();

            $options = [
                'A' => 'Ribosom',
                'B' => 'Nukleus',
                'C' => 'Mitokondria',
                'D' => 'Lisosom',
            ];

            foreach ($options as $label => $text) {
                DB::table('question_options')->updateOrInsert(
                    [
                        'question_id' => $question->id,
                        'option_label' => $label,
                    ],
                    [
                        'option_text' => $text,
                        'is_correct' => $label === 'B',
                        'updated_at' => $now,
                    ]
                );
            }
        });

        $this->command->info(
            'Modul 2 Struktur Sel berhasil disiapkan.'
        );
    }
}
