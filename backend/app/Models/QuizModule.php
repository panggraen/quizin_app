<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QuizModule extends Model
{
    protected $table = 'quiz_modules';

    protected $fillable = [
        'material_id',
        'title',
        'description',
        'module_number',
        'is_published',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'module_number' => 'integer',
            'is_published' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function material(): BelongsTo
    {
        return $this->belongsTo(Material::class, 'material_id');
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class, 'quiz_module_id');
    }

    public function attempts(): HasMany
    {
        return $this->hasMany(QuizAttempt::class, 'quiz_module_id');
    }

    public function userProgress(): HasMany
    {
        return $this->hasMany(UserModuleProgress::class, 'quiz_module_id');
    }
}
