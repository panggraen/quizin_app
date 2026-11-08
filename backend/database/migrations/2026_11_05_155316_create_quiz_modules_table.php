
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quiz_modules', function (Blueprint $table) {
            $table->id();

            $table->foreignId('material_id')
                ->constrained('materials')
                ->restrictOnDelete();

            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->unsignedInteger('module_number');
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->unique(['material_id', 'module_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quiz_modules');
    }
};
