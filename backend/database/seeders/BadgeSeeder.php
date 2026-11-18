<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BadgeSeeder extends Seeder
{
    public function run(): void
    {
        $badges = [
            [
                'name' => 'Pemula',
                'slug' => 'pemula',
                'description' => 'Menyelesaikan 1 modul kuis.',
                'icon_path' => null,
                'required_modules' => 1,
            ],
            [
                'name' => 'Penjelajah',
                'slug' => 'penjelajah',
                'description' => 'Menyelesaikan 5 modul kuis.',
                'icon_path' => null,
                'required_modules' => 5,
            ],
            [
                'name' => 'Ahli',
                'slug' => 'ahli',
                'description' => 'Menyelesaikan 10 modul kuis.',
                'icon_path' => null,
                'required_modules' => 10,
            ],
        ];

        foreach ($badges as $badge) {
            DB::table('badges')->insertOrIgnore([
                ...$badge,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('Data badge awal berhasil diproses.');
    }
}
