<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_daily_checkins', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->restrictOnDelete();

            $table->date('checkin_date');

            $table->unsignedInteger('xp_awarded')
                ->default(10);

            $table->timestamps();

            // Satu pengguna hanya boleh check-in
            // satu kali pada tanggal yang sama.
            $table->unique(
                ['user_id', 'checkin_date'],
                'unique_user_daily_checkin'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_daily_checkins');
    }
};
