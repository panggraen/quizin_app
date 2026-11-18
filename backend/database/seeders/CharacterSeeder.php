<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CharacterSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('characters')->updateOrInsert(
            ['slug' => 'nimbi'],
            [
                'name' => 'Nimbi',
                'description' => 'Karakter awal QUIZIN yang menemani perjalanan belajar pengguna.',
                'image_path' => 'characters/nimbi.png',
                'price_coins' => 0,
                'is_default' => true,
                'is_published' => true,
                'sort_order' => 1,
                'updated_at' => now(),
            ]
        );
    }
}
