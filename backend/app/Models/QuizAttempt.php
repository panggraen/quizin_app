<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class QuizAttempt extends Model
{
    protected $table = 'quiz_attempts';

    protected $fillable = [
        'user_id',
        'quiz_module_id',
        'status',
        'total_questions',
        'correct_answers',
        'score',
        'started_at',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'total_questions' => 'integer',
            'correct_answers' => 'integer',
            'score' => 'integer',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
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

    public function answers(): HasMany
    {
        return $this->hasMany(QuizAttemptAnswer::class, 'quiz_attempt_id');
    }

    public function firstCompletionProgress(): HasOne
    {
        return $this->hasOne(UserModuleProgress::class, 'first_completed_attempt_id');
    }

    public function coinTransaction(): HasOne
    {
        return $this->hasOne(CoinTransaction::class, 'quiz_attempt_id');
    }
}
