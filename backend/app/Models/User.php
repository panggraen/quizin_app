<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function stats(): HasOne
    {
        return $this->hasOne(UserStat::class, 'user_id');
    }

    public function quizAttempts(): HasMany
    {
        return $this->hasMany(QuizAttempt::class, 'user_id');
    }

    public function materialProgress(): HasMany
    {
        return $this->hasMany(UserMaterialProgress::class, 'user_id');
    }

    public function moduleProgress(): HasMany
    {
        return $this->hasMany(UserModuleProgress::class, 'user_id');
    }

    public function ownedCharacters(): HasMany
    {
        return $this->hasMany(UserCharacter::class, 'user_id');
    }

    public function badges(): HasMany
    {
        return $this->hasMany(UserBadge::class, 'user_id');
    }

    public function coinTransactions(): HasMany
    {
        return $this->hasMany(CoinTransaction::class, 'user_id');
    }
}
