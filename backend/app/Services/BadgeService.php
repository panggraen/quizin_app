<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class BadgeService
{
    public function awardEligibleBadges(int $userId): array
    {
        // Hitung jumlah modul unik yang sudah selesai.
        $completedModules = DB::table('user_module_progress')
            ->where('user_id', $userId)
            ->whereNotNull('first_completed_at')
            ->distinct()
            ->count('quiz_module_id');

        // Cari badge aktif yang syaratnya terpenuhi.
        $badges = DB::table('badges')
            ->where('is_active', true)
            ->where('required_modules', '<=', $completedModules)
            ->orderBy('required_modules')
            ->get();

        $newBadges = [];

        foreach ($badges as $badge) {

            // Jangan memberikan badge yang sudah dimiliki.
            $alreadyOwned = DB::table('user_badges')
                ->where('user_id', $userId)
                ->where('badge_id', $badge->id)
                ->exists();

            if ($alreadyOwned) {
                continue;
            }

            DB::table('user_badges')->insert([
                'user_id' => $userId,
                'badge_id' => $badge->id,
                'earned_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $newBadges[] = [
                'id' => $badge->id,
                'name' => $badge->name,
            ];
        }

        return $newBadges;
    }
}
