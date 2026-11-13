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

            // Modul milik bidang (subject): Biologi -> modul 1..N.
            $table->foreignId('subject_id')
                ->constrained('subjects')
                ->restrictOnDelete();

            // Materi terkait (opsional, untuk tombol "Baca Materi").
            $table->foreignId('material_id')
                ->nullable()
                ->constrained('materials')
                ->nullOnDelete();

            $table->string('title', 150);
            $table->text('description')->nullable();
            $table->unsignedInteger('module_number');
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->unique(['subject_id', 'module_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quiz_modules');
    }
};