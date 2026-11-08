<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStat extends Model
{
    protected $table = 'user_stats';

    protected $fillable = [
        'user_id',
        'total_xp',
        'level',
        'coin_balance',
        'active_character_id',
    ];

    protected function casts(): array
    {
        return [
            'total_xp' => 'integer',
            'level' => 'integer',
            'coin_balance' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function activeCharacter(): BelongsTo
    {
        return $this->belongsTo(Character::class, 'active_character_id');
    }
}
