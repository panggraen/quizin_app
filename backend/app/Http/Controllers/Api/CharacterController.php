<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CharacterController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = DB::table('user_stats')
            ->where('user_id', $user->id)
            ->first();

        $ownedCharacterIds = DB::table('user_characters')
            ->where('user_id', $user->id)
            ->pluck('character_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $characters = DB::table('characters')
            ->where('is_published', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(function ($character) use ($ownedCharacterIds, $stats) {
                return [
                    'id' => $character->id,
                    'name' => $character->name,
                    'description' => $character->description,
                    'image_path' => $character->image_path,
                    'price_coins' => (int) $character->price_coins,
                    'is_default' => (bool) $character->is_default,
                    'is_owned' => in_array(
                        (int) $character->id,
                        $ownedCharacterIds,
                        true
                    ),
                    'is_active' => $stats
                        && (int) $stats->active_character_id === (int) $character->id,
                ];
            });

        return response()->json([
            'message' => 'Daftar karakter berhasil diambil.',
            'coin_balance' => (int) ($stats->coin_balance ?? 0),
            'data' => $characters,
        ]);
    }

public function purchase(Request $request, int $character): JsonResponse
{
    $user = $request->user();

    return DB::transaction(function () use ($user, $character) {

        // Kunci saldo agar pembelian bersamaan tidak
        // menyebabkan saldo digunakan dua kali.
        $stats = DB::table('user_stats')
            ->where('user_id', $user->id)
            ->lockForUpdate()
            ->first();

        if (!$stats) {
            return response()->json([
                'message' => 'Statistik pengguna tidak ditemukan.',
            ], 409);
        }

        $item = DB::table('characters')
            ->where('id', $character)
            ->where('is_published', true)
            ->first();

        if (!$item) {
            return response()->json([
                'message' => 'Karakter tidak ditemukan.',
            ], 404);
        }

        // Karakter awal tidak perlu dibeli.
        if ($item->is_default || $item->price_coins == 0) {
            return response()->json([
                'message' => 'Karakter gratis tidak perlu dibeli.',
            ], 422);
        }

        // Pastikan belum dimiliki.
        $alreadyOwned = DB::table('user_characters')
            ->where('user_id', $user->id)
            ->where('character_id', $item->id)
            ->exists();

        if ($alreadyOwned) {
            return response()->json([
                'message' => 'Karakter sudah dimiliki.',
            ], 409);
        }

        $price = (int) $item->price_coins;
        $balance = (int) $stats->coin_balance;

        if ($balance < $price) {
            return response()->json([
                'message' => 'Koin tidak mencukupi.',
                'coin_balance' => $balance,
                'required_coins' => $price,
            ], 422);
        }

        $newBalance = $balance - $price;

        // Kurangi saldo koin.
        DB::table('user_stats')
            ->where('id', $stats->id)
            ->update([
                'coin_balance' => $newBalance,
                'updated_at' => now(),
            ]);

        // Simpan kepemilikan permanen.
        DB::table('user_characters')->insert([
            'user_id' => $user->id,
            'character_id' => $item->id,
            'obtained_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Catat riwayat transaksi pembelian.
        DB::table('coin_transactions')->insert([
            'user_id' => $user->id,
            'type' => 'character_purchase',
            'amount' => -$price,
            'balance_after' => $newBalance,
            'character_id' => $item->id,
            'description' => 'Pembelian karakter: ' . $item->name,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'message' => 'Karakter berhasil dibeli.',
            'data' => [
                'character_id' => $item->id,
                'character_name' => $item->name,
                'coins_spent' => $price,
                'coin_balance' => $newBalance,
                'is_owned' => true,
            ],
        ]);
    }, 3);
}

public function activate(Request $request, int $character): JsonResponse
{
    $user = $request->user();

    // Pastikan karakter tersedia dan dipublikasikan.
    $item = DB::table('characters')
        ->where('id', $character)
        ->where('is_published', true)
        ->first();

    if (!$item) {
        return response()->json([
            'message' => 'Karakter tidak ditemukan.',
        ], 404);
    }

    // Pengguna hanya boleh memakai karakter miliknya.
    $isOwned = DB::table('user_characters')
        ->where('user_id', $user->id)
        ->where('character_id', $character)
        ->exists();

    if (!$isOwned) {
        return response()->json([
            'message' => 'Karakter belum dimiliki.',
        ], 403);
    }

    // Perbarui karakter aktif tanpa mengurangi koin.
    $updated = DB::table('user_stats')
        ->where('user_id', $user->id)
        ->update([
            'active_character_id' => $character,
            'updated_at' => now(),
        ]);

    if (!$updated) {
        return response()->json([
            'message' => 'Statistik pengguna tidak ditemukan.',
        ], 409);
    }

    return response()->json([
        'message' => 'Karakter berhasil diaktifkan.',
        'data' => [
            'character_id' => $item->id,
            'character_name' => $item->name,
            'is_active' => true,
        ],
    ]);
}

}
