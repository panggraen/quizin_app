<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class QuizModuleSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {

            // Cari materi Pengenalan Sel yang sudah tersedia.
            $material = DB::table('materials')
                ->where('slug', 'pengenalan-sel')
                ->first();

            if (!$material) {
                throw new RuntimeException(
                    'Materi Pengenalan Sel tidak ditemukan. Jalankan QuizContentSeeder terlebih dahulu.'
                );
            }

            $now = now();

            // Buat atau perbarui Modul 1.
            DB::table('quiz_modules')->updateOrInsert(
                [
                    'material_id' => $material->id,
                    'module_number' => 1,
                ],
                [
                    'title' => 'Modul 1 - Pengenalan Sel',
                    'description' => 'Kuis dasar mengenai struktur dan fungsi sel.',
                    'is_published' => true,
                    'published_at' => $now,
                    'updated_at' => $now,
                ]
            );

            $module = DB::table('quiz_modules')
                ->where('material_id', $material->id)
                ->where('module_number', 1)
                ->first();

            $questions = [
                [
                    'text' => 'Apa yang dimaksud dengan sel?',
                    'explanation' => 'Sel merupakan unit struktural dan fungsional terkecil penyusun makhluk hidup.',
                    'correct' => 'A',
                    'options' => [
                        'A' => 'Unit terkecil penyusun makhluk hidup',
                        'B' => 'Kumpulan beberapa organ',
                        'C' => 'Bagian dari sistem organ',
                        'D' => 'Jaringan yang membentuk tubuh',
                    ],
                ],
                [
                    'text' => 'Organel apa yang berfungsi menghasilkan energi melalui respirasi sel?',
                    'explanation' => 'Mitokondria menjadi tempat utama respirasi sel aerob yang menghasilkan ATP.',
                    'correct' => 'B',
                    'options' => [
                        'A' => 'Ribosom',
                        'B' => 'Mitokondria',
                        'C' => 'Badan Golgi',
                        'D' => 'Lisosom',
                    ],
                ],
                [
                    'text' => 'Apa fungsi utama membran sel?',
                    'explanation' => 'Membran sel mengatur perpindahan zat ke dalam dan ke luar sel.',
                    'correct' => 'C',
                    'options' => [
                        'A' => 'Menghasilkan seluruh energi sel',
                        'B' => 'Menyimpan informasi genetik',
                        'C' => 'Mengatur keluar masuknya zat',
                        'D' => 'Membentuk protein secara langsung',
                    ],
                ],
                [
                    'text' => 'Organel apa yang berperan dalam sintesis protein?',
                    'explanation' => 'Ribosom merupakan tempat berlangsungnya sintesis protein.',
                    'correct' => 'A',
                    'options' => [
                        'A' => 'Ribosom',
                        'B' => 'Vakuola',
                        'C' => 'Kloroplas',
                        'D' => 'Lisosom',
                    ],
                ],
                [
                    'text' => 'Struktur apa yang mengandung sebagian besar DNA pada sel eukariotik?',
                    'explanation' => 'Inti sel atau nukleus menyimpan sebagian besar materi genetik sel eukariotik.',
                    'correct' => 'D',
                    'options' => [
                        'A' => 'Dinding sel',
                        'B' => 'Sitoplasma',
                        'C' => 'Membran plasma',
                        'D' => 'Inti sel',
                    ],
                ],
            ];

            foreach ($questions as $index => $item) {

                $number = $index + 1;

                DB::table('questions')->updateOrInsert(
                    [
                        'quiz_module_id' => $module->id,
                        'sort_order' => $number,
                    ],
                    [
                        'question_text' => $item['text'],
                        'explanation' => $item['explanation'],
                        'updated_at' => $now,
                    ]
                );

                $question = DB::table('questions')
                    ->where('quiz_module_id', $module->id)
                    ->where('sort_order', $number)
                    ->first();

                foreach ($item['options'] as $label => $text) {
                    DB::table('question_options')->updateOrInsert(
                        [
                            'question_id' => $question->id,
                            'option_label' => $label,
                        ],
                        [
                            'option_text' => $text,
                            'is_correct' => $label === $item['correct'],
                            'updated_at' => $now,
                        ]
                    );
                }
            }
        });

        $this->command->info(
            'Modul 1 Pengenalan Sel berhasil disiapkan.'
        );
    }
}
