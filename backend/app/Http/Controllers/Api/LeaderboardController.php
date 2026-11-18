<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LeaderboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $myStats = DB::table('user_stats')
            ->where('user_id', $user->id)
            ->first();

        if (!$myStats) {
            return response()->json([
                'message' => 'Statistik pengguna tidak ditemukan.',
            ], 409);
        }

        // Ambil 10 pengguna dengan total XP tertinggi.
        $topUsers = DB::table('user_stats as stats')
            ->join('users', 'users.id', '=', 'stats.user_id')
            ->select(
                'stats.user_id',
                'users.name',
                'stats.total_xp',
                'stats.level'
            )
            ->orderByDesc('stats.total_xp')
            ->orderBy('stats.user_id')
            ->limit(10)
            ->get();

        // Pengguna dengan XP sama memiliki peringkat sama.
        $lastXp = null;
        $rank = 0;

        $leaderboard = $topUsers->map(
            function ($item, $index) use (&$lastXp, &$rank, $user) {

                $xp = (int) $item->total_xp;

                if ($lastXp === null || $xp !== $lastXp) {
                    $rank = $index + 1;
                }

                $lastXp = $xp;

                return [
                    'rank' => $rank,
                    'user_id' => $item->user_id,
                    'name' => $item->name,
                    'total_xp' => $xp,
                    'level' => (int) $item->level,
                    'is_me' => (int) $item->user_id === (int) $user->id,
                ];
            }
        );

        // Posisi pengguna sendiri, meskipun tidak masuk 10 besar.
        $myRank = DB::table('user_stats')
            ->where('total_xp', '>', $myStats->total_xp)
            ->count() + 1;

        $totalUsers = DB::table('user_stats')->count();

        return response()->json([
            'message' => 'Leaderboard berhasil diambil.',
            'data' => [
                'total_users' => $totalUsers,
                'my_rank' => $myRank,
                'my_stats' => [
                    'user_id' => $user->id,
                    'name' => $user->name,
                    'total_xp' => (int) $myStats->total_xp,
                    'level' => (int) $myStats->level,
                ],
                'leaderboard' => $leaderboard,
            ],
        ]);
    }
}
