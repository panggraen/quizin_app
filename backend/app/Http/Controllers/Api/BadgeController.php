<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BadgeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        // Hitung modul unik yang telah diselesaikan.
        $completedModules = DB::table('user_module_progress')
            ->where('user_id', $userId)
            ->whereNotNull('first_completed_at')
            ->distinct()
            ->count('quiz_module_id');

        // Ambil badge aktif beserta status kepemilikannya.
        $badges = DB::table('badges')
            ->leftJoin('user_badges', function ($join) use ($userId) {
                $join->on(
                    'badges.id',
                    '=',
                    'user_badges.badge_id'
                )->where('user_badges.user_id', '=', $userId);
            })
            ->where('badges.is_active', true)
            ->select(
                'badges.id',
                'badges.name',
                'badges.slug',
                'badges.description',
                'badges.icon_path',
                'badges.required_modules',
                'user_badges.earned_at'
            )
            ->orderBy('badges.required_modules')
            ->get()
            ->map(function ($badge) use ($completedModules) {
                return [
                    'id' => $badge->id,
                    'name' => $badge->name,
                    'slug' => $badge->slug,
                    'description' => $badge->description,
                    'icon_path' => $badge->icon_path,
                    'required_modules' => (int) $badge->required_modules,
                    'is_earned' => $badge->earned_at !== null,
                    'earned_at' => $badge->earned_at,
                    'remaining_modules' => max(
                        0,
                        (int) $badge->required_modules - $completedModules
                    ),
                ];
            });

        return response()->json([
            'message' => 'Daftar badge berhasil diambil.',
            'data' => [
                'completed_modules' => $completedModules,
                'earned_badges' => $badges
                    ->where('is_earned', true)
                    ->count(),
                'total_badges' => $badges->count(),
                'badges' => $badges->values(),
            ],
        ]);
    }
}
