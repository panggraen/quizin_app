<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AssignDefaultCharacterSeeder extends Seeder
{
    public function run(): void
    {
        $defaultCharacter = DB::table('characters')
            ->where('is_default', true)
            ->where('is_published', true)
            ->first();

        if (!$defaultCharacter) {
            $this->command->warn(
                'Karakter awal belum tersedia.'
            );
            return;
        }

        DB::table('users')
            ->orderBy('id')
            ->chunk(100, function ($users) use ($defaultCharacter) {

                foreach ($users as $user) {

                    // Berikan kepemilikan tanpa duplikasi.
                    DB::table('user_characters')->insertOrIgnore([
                        'user_id' => $user->id,
                        'character_id' => $defaultCharacter->id,
                        'obtained_at' => now(),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);

                    // Aktifkan karakter awal hanya jika
                    // pengguna belum memakai karakter.
                    DB::table('user_stats')
                        ->where('user_id', $user->id)
                        ->whereNull('active_character_id')
                        ->update([
                            'active_character_id' => $defaultCharacter->id,
                            'updated_at' => now(),
                        ]);
                }
            });

        $this->command->info(
            'Karakter awal berhasil diberikan kepada pengguna.'
        );
    }
}
