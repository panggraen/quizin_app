
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_characters', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->restrictOnDelete();

            $table->foreignId('character_id')
                ->constrained('characters')
                ->restrictOnDelete();

            $table->timestamp('obtained_at')->useCurrent();
            $table->timestamps();

            $table->unique(['user_id', 'character_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_characters');
    }
};
