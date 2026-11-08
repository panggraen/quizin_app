
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_module_progress', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->restrictOnDelete();

            $table->foreignId('quiz_module_id')
                ->constrained('quiz_modules')
                ->restrictOnDelete();

            $table->foreignId('first_completed_attempt_id')
                ->nullable()
                ->constrained('quiz_attempts')
                ->restrictOnDelete();

            $table->unsignedInteger('best_score')->default(0);
            $table->unsignedInteger('attempt_count')->default(0);

            $table->timestamp('first_completed_at')->nullable();
            $table->timestamp('last_completed_at')->nullable();

            $table->unsignedInteger('xp_awarded')->default(0);
            $table->unsignedInteger('coins_awarded')->default(0);

            $table->timestamps();

            $table->unique(['user_id', 'quiz_module_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_module_progress');
    }
};
