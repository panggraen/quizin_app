
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coin_transactions', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->restrictOnDelete();

            $table->enum('type', [
                'quiz_reward',
                'character_purchase'
            ]);

            $table->integer('amount');
            $table->unsignedBigInteger('balance_after');

            $table->foreignId('quiz_attempt_id')
                ->nullable()
                ->constrained('quiz_attempts')
                ->restrictOnDelete();

            $table->foreignId('character_id')
                ->nullable()
                ->constrained('characters')
                ->restrictOnDelete();

            $table->text('description')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'created_at']);

            $table->unique('quiz_attempt_id');
            $table->unique(['user_id', 'character_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coin_transactions');
    }
};
