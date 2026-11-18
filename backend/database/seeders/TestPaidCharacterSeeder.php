<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TestPaidCharacterSeeder extends Seeder
{
    public function run(): void
    {
        // Tambahkan karakter pengujian jika belum tersedia.
        DB::table('characters')->insertOrIgnore([
            'name' => 'Bubu Uji',
            'slug' => 'bubu-uji',
            'description' => 'Karakter berbayar untuk pengujian toko QUIZIN.',
            'image_path' => 'characters/bubu-uji.png',
            'price_coins' => 3,
            'is_default' => false,
            'is_published' => true,
            'sort_order' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->command->info(
            'Seeder karakter Bubu Uji selesai dijalankan.'
        );
    }
}
