<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Material extends Model
{
    protected $table = 'materials';

    protected $fillable = [
        'subject_id',
        'title',
        'slug',
        'content',
        'summary',
        'sort_order',
        'is_published',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'is_published' => 'boolean',
            'sort_order' => 'integer',
            'published_at' => 'datetime',
        ];
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class, 'subject_id');
    }

    public function quizModules(): HasMany
    {
        return $this->hasMany(QuizModule::class, 'material_id');
    }

    public function userProgress(): HasMany
    {
        return $this->hasMany(UserMaterialProgress::class, 'material_id');
    }
}
