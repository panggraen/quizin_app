<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserCharacter extends Model
{
    protected $table = 'user_characters';

    protected $fillable = [
        'user_id',
        'character_id',
        'obtained_at',
    ];

    protected function casts(): array
    {
        return [
            'obtained_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function character(): BelongsTo
    {
        return $this->belongsTo(Character::class, 'character_id');
    }
}
