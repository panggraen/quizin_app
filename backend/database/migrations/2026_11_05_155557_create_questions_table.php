
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('questions', function (Blueprint $table) {
            $table->id();

            $table->foreignId('quiz_module_id')
                ->constrained('quiz_modules')
                ->restrictOnDelete();

            $table->text('question_text');
            $table->text('explanation')->nullable();
            $table->unsignedInteger('sort_order');
            $table->timestamps();

            $table->unique(['quiz_module_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
