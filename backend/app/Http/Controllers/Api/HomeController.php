<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HomeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = DB::table('user_stats')
            ->where('user_id', $user->id)
            ->first();

        if (!$stats) {
            return response()->json([
                'message' => 'Statistik pengguna tidak ditemukan.',
            ], 409);
        }

        // Progres hanya dari materi yang tersedia.
        $materials = DB::table('materials as m')
            ->join('subjects as s', 's.id', '=', 'm.subject_id')
            ->join('categories as c', 'c.id', '=', 's.category_id')
            ->where('m.is_published', true)
            ->where('s.is_active', true)
            ->where('c.is_active', true);

        $totalMaterials = (clone $materials)->count();

        $completedMaterials = (clone $materials)
            ->join('user_material_progress as p', 'p.material_id', '=', 'm.id')
            ->where('p.user_id', $user->id)
            ->where('p.is_completed', true)
            ->distinct()
            ->count('m.id');

        $materialPercentage = $totalMaterials > 0
            ? round($completedMaterials / $totalMaterials * 100, 2)
            : 0;

        // Tanggal absensi dihitung berdasarkan WIB.
        $today = CarbonImmutable::now('Asia/Jakarta');
        $start = $today->startOfWeek(CarbonInterface::MONDAY);
        $end = $start->addDays(6);

        $checkedDates = DB::table('user_daily_checkins')
            ->where('user_id', $user->id)
            ->whereBetween('checkin_date', [
                $start->toDateString(),
                $end->toDateString(),
            ])
            ->pluck('checkin_date')
            ->map(fn ($date) => substr((string) $date, 0, 10))
            ->all();

        $checkedSet = array_fill_keys($checkedDates, true);

        $dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        $days = [];

        for ($i = 0; $i < 7; $i++) {
            $date = $start->addDays($i)->toDateString();

            $days[] = [
                'day' => $dayNames[$i],
                'date' => $date,
                'is_checked_in' => isset($checkedSet[$date]),
            ];
        }

        $xp = (int) $stats->total_xp;
        $xpInCurrentLevel = $xp % 100;

        return response()->json([
            'message' => 'Data Home berhasil diambil.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                ],
                'stats' => [
                    'total_xp' => $xp,
                    'level' => (int) $stats->level,
                    'coin_balance' => (int) $stats->coin_balance,
                    'active_character_id' => $stats->active_character_id,
                    'xp_in_current_level' => $xpInCurrentLevel,
                    'xp_to_next_level' => 100 - $xpInCurrentLevel,
                    'xp_required_per_level' => 100,
                ],
                'material_progress' => [
                    'total_materials' => $totalMaterials,
                    'completed_materials' => $completedMaterials,
                    'progress_percentage' => $materialPercentage,
                ],
                'weekly_checkin' => [
                    'week_start' => $start->toDateString(),
                    'week_end' => $end->toDateString(),
                    'today' => $today->toDateString(),
                    'checked_in_today' => isset(
                        $checkedSet[$today->toDateString()]
                    ),
                    'total_checkins' => count($checkedSet),
                    'days' => $days,
                ],
            ],
        ]);
    }
}
