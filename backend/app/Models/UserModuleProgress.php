<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserModuleProgress extends Model
{
    protected $table = 'user_module_progress';

    protected $fillable = [
        'user_id',
        'quiz_module_id',
        'first_completed_attempt_id',
        'best_score',
        'attempt_count',
        'first_completed_at',
        'last_completed_at',
        'xp_awarded',
        'coins_awarded',
    ];

    protected function casts(): array
    {
        return [
            'best_score' => 'integer',
            'attempt_count' => 'integer',
            'xp_awarded' => 'integer',
            'coins_awarded' => 'integer',
            'first_completed_at' => 'datetime',
            'last_completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function quizModule(): BelongsTo
    {
        return $this->belongsTo(QuizModule::class, 'quiz_module_id');
    }

    public function firstCompletedAttempt(): BelongsTo
    {
        return $this->belongsTo(QuizAttempt::class, 'first_completed_attempt_id');
    }
}
