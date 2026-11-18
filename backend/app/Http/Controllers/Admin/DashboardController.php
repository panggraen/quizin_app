<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $stats = [
            'users' => DB::table('users')
                ->where('role', 'user')->count(),
            'materials' => DB::table('materials')->count(),
            'modules' => DB::table('quiz_modules')->count(),
            'characters' => DB::table('characters')->count(),
            'badges' => DB::table('badges')->count(),
            'categories' => DB::table('categories')->count(),
        ];

        $today = CarbonImmutable::now('Asia/Jakarta');
        $start = $today->subDays(29);

        $registrations = DB::table('users')
            ->where('role', 'user')
            ->whereDate('created_at', '>=', $start->toDateString())
            ->selectRaw('DATE(created_at) as day, COUNT(*) as total')
            ->groupByRaw('DATE(created_at)')
            ->pluck('total', 'day');

        $dates = [];
        $values = [];

        for ($i = 29; $i >= 0; $i--) {
            $date = $today->subDays($i)->toDateString();

            $dates[] = $date;
            $values[] = (int) ($registrations[$date] ?? 0);
        }

        $maxValue = max(1, max($values));
        $points = [];

        foreach ($values as $index => $value) {
            $x = round(22 + ($index * 756 / 29), 2);
            $y = round(190 - ($value / $maxValue * 150), 2);

            $points[] = "$x,$y";
        }

        $chart = [
            'line' => implode(' ', $points),
            'area' => '22,190 ' . implode(' ', $points)
                . ' 778,190',
            'labels' => [],
        ];

        foreach ([0, 5, 10, 15, 20, 25, 29] as $index) {
            $chart['labels'][] = CarbonImmutable::parse(
                $dates[$index]
            )->locale('id')->translatedFormat('d M');
        }

        $contentTotal = $stats['categories']
            + $stats['materials']
            + $stats['modules'];

        $categoryEnd = $contentTotal > 0
            ? round(
                $stats['categories'] / $contentTotal * 100,
                2
            )
            : 0;

        $materialEnd = $contentTotal > 0
            ? round(
                ($stats['categories'] + $stats['materials'])
                / $contentTotal * 100,
                2
            )
            : 0;

        $donutBackground = $contentTotal > 0
            ? "conic-gradient(
                #7198D0 0% {$categoryEnd}%,
                #66CA94 {$categoryEnd}% {$materialEnd}%,
                #FFD45C {$materialEnd}% 100%
              )"
            : '#E5EAF2';

        $recentUsers = DB::table('users')
            ->where('role', 'user')
            ->orderByDesc('id')
            ->limit(5)
            ->get(['id', 'name', 'created_at']);

        $recentMaterials = DB::table('materials')
            ->orderByDesc('id')
            ->limit(5)
            ->get();

        return view('admin.dashboard', compact(
            'stats',
            'chart',
            'contentTotal',
            'donutBackground',
            'recentUsers',
            'recentMaterials'
        ));
    }
}
