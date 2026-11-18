<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DailyCheckinController extends Controller
{
    private const TIMEZONE = 'Asia/Jakarta';
    private const XP_REWARD = 10;
    private const WEEKLY_TARGET = 5;

    /**
     * Mengambil seluruh tanggal check-in pengguna.
     */
    private function getCheckinDates(int $userId): array
    {
        return DB::table('user_daily_checkins')
            ->where('user_id', $userId)
            ->orderBy('checkin_date')
            ->pluck('checkin_date')
            ->map(fn ($date) => substr((string) $date, 0, 10))
            ->unique()
            ->values()
            ->all();
    }

    /**
     * Menghitung current streak dan best streak.
     *
     * Streak tetap aktif jika check-in terakhir
     * dilakukan hari ini atau kemarin.
     */
    private function calculateStreaks(
        array $dates,
        CarbonImmutable $today
    ): array {
        if (empty($dates)) {
            return [
                'current_streak' => 0,
                'best_streak' => 0,
            ];
        }

        $consecutiveDays = 0;
        $bestStreak = 0;
        $previousDate = null;

        foreach ($dates as $date) {
            $isConsecutive = $previousDate !== null
                && CarbonImmutable::parse(
                    $previousDate,
                    self::TIMEZONE
                )->addDay()->toDateString() === $date;

            if ($isConsecutive) {
                $consecutiveDays++;
            } else {
                $consecutiveDays = 1;
            }

            $bestStreak = max(
                $bestStreak,
                $consecutiveDays
            );

            $previousDate = $date;
        }

        $todayDate = $today->toDateString();
        $yesterdayDate = $today->subDay()->toDateString();

        $streakStillActive = in_array(
            $previousDate,
            [$todayDate, $yesterdayDate],
            true
        );

        return [
            'current_streak' => $streakStillActive
                ? $consecutiveDays
                : 0,
            'best_streak' => $bestStreak,
        ];
    }

    /**
     * GET /api/checkins/weekly
     *
     * Menampilkan progres check-in mingguan
     * sekaligus informasi streak pengguna.
     */
    public function weekly(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $today = CarbonImmutable::now(self::TIMEZONE);

        $start = $today->startOfWeek(
            CarbonInterface::MONDAY
        );

        $end = $start->addDays(6);

        // Ambil riwayat check-in.
        $allCheckinDates = $this->getCheckinDates($userId);

        // Ambil hanya tanggal pada minggu berjalan.
        $weeklyCheckins = array_values(
            array_filter(
                $allCheckinDates,
                fn ($date) =>
                    $date >= $start->toDateString()
                    && $date <= $end->toDateString()
            )
        );

        $checkedDates = array_fill_keys(
            $weeklyCheckins,
            true
        );

        $days = [];

        $dayNames = [
            'Sen',
            'Sel',
            'Rab',
            'Kam',
            'Jum',
            'Sab',
            'Min',
        ];

        for ($i = 0; $i < 7; $i++) {
            $date = $start
                ->addDays($i)
                ->toDateString();

            $days[] = [
                'day' => $dayNames[$i],
                'date' => $date,
                'is_checked_in' => isset(
                    $checkedDates[$date]
                ),
            ];
        }

        $totalCheckins = count($weeklyCheckins);

        // Hitung current dan best streak.
        $streaks = $this->calculateStreaks(
            $allCheckinDates,
            $today
        );

        return response()->json([
            'message' =>
                'Data check-in mingguan berhasil diambil.',
            'data' => [
                'week_start' => $start->toDateString(),
                'week_end' => $end->toDateString(),
                'today' => $today->toDateString(),

                'checked_in_today' => isset(
                    $checkedDates[$today->toDateString()]
                ),

                'total_checkins' => $totalCheckins,

                // Target check-in mingguan.
                'weekly_target' => self::WEEKLY_TARGET,
                'weekly_target_met' =>
                    $totalCheckins >= self::WEEKLY_TARGET,

                'remaining_checkins' => max(
                    0,
                    self::WEEKLY_TARGET - $totalCheckins
                ),

                // Statistik streak pengguna.
                'current_streak' =>
                    $streaks['current_streak'],

                'best_streak' =>
                    $streaks['best_streak'],

                'days' => $days,
            ],
        ]);
    }

    /**
     * POST /api/checkins
     *
     * Check-in hanya sekali dalam satu hari WIB.
     * Hadiah tetap 10 XP dan tanpa tambahan koin.
     */
    public function store(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $todayCarbon = CarbonImmutable::now(
            self::TIMEZONE
        );

        $today = $todayCarbon->toDateString();

        $result = DB::transaction(function () use (
            $userId,
            $today
        ) {
            // Kunci statistik agar permintaan bersamaan
            // tidak memberikan XP dua kali.
            $stats = DB::table('user_stats')
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->first();

            if (!$stats) {
                return ['error' => true];
            }

            // Periksa apakah sudah check-in hari ini.
            $existing = DB::table('user_daily_checkins')
                ->where('user_id', $userId)
                ->where('checkin_date', $today)
                ->first();

            if ($existing) {
                return [
                    'already_checked_in' => true,
                    'xp_awarded' => 0,
                    'total_xp' => (int) $stats->total_xp,
                    'level' => (int) $stats->level,
                ];
            }

            $now = now();

            // Catat check-in pengguna.
            DB::table('user_daily_checkins')->insert([
                'user_id' => $userId,
                'checkin_date' => $today,
                'xp_awarded' => self::XP_REWARD,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            // Berikan 10 XP.
            $newTotalXp = (int) $stats->total_xp
                + self::XP_REWARD;

            $newLevel = intdiv($newTotalXp, 100) + 1;

            DB::table('user_stats')
                ->where('user_id', $userId)
                ->update([
                    'total_xp' => $newTotalXp,
                    'level' => $newLevel,
                    'updated_at' => $now,
                ]);

            return [
                'already_checked_in' => false,
                'xp_awarded' => self::XP_REWARD,
                'total_xp' => $newTotalXp,
                'level' => $newLevel,
            ];
        }, 3);

        if (isset($result['error'])) {
            return response()->json([
                'message' =>
                    'Data statistik pengguna tidak ditemukan.',
            ], 409);
        }

        // Hitung streak setelah transaksi check-in selesai.
        $allCheckinDates = $this->getCheckinDates(
            $userId
        );

        $streaks = $this->calculateStreaks(
            $allCheckinDates,
            $todayCarbon
        );

        return response()->json([
            'message' => $result['already_checked_in']
                ? 'Kamu sudah check-in hari ini.'
                : 'Check-in berhasil! Kamu mendapatkan 10 XP.',

            'data' => [
                'checkin_date' => $today,

                ...$result,

                'current_streak' =>
                    $streaks['current_streak'],

                'best_streak' =>
                    $streaks['best_streak'],
            ],
        ]);
    }
}
