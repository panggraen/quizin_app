<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Character extends Model
{
    protected $table = 'characters';

    protected $fillable = [
        'name',
        'slug',
        'description',
        'image_path',
        'price_coins',
        'is_default',
        'is_published',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'price_coins' => 'integer',
            'is_default' => 'boolean',
            'is_published' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function owners(): HasMany
    {
        return $this->hasMany(UserCharacter::class, 'character_id');
    }

    public function activeUsers(): HasMany
    {
        return $this->hasMany(UserStat::class, 'active_character_id');
    }

    public function coinTransactions(): HasMany
    {
        return $this->hasMany(CoinTransaction::class, 'character_id');
    }
}
