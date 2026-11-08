
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quiz_attempt_answers', function (Blueprint $table) {
            $table->id();

            $table->foreignId('quiz_attempt_id')
                ->constrained('quiz_attempts')
                ->restrictOnDelete();

            $table->foreignId('question_id')
                ->constrained('questions')
                ->restrictOnDelete();

            $table->foreignId('question_option_id')
                ->constrained('question_options')
                ->restrictOnDelete();

            $table->boolean('is_correct');
            $table->timestamp('answered_at')->useCurrent();
            $table->timestamps();

            $table->unique(
                ['quiz_attempt_id', 'question_id'],
                'unique_attempt_question'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quiz_attempt_answers');
    }
};
