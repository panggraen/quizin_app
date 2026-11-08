<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Badge extends Model
{
    protected $table = 'badges';

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon_path',
        'required_modules',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'required_modules' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function owners(): HasMany
    {
        return $this->hasMany(UserBadge::class, 'badge_id');
    }
}
