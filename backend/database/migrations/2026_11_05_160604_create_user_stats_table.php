
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_stats', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->unique()
                ->constrained('users')
                ->restrictOnDelete();

            $table->unsignedBigInteger('total_xp')->default(0);
            $table->unsignedInteger('level')->default(1);
            $table->unsignedBigInteger('coin_balance')->default(0);

            $table->timestamps();

            $table->index('total_xp');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_stats');
    }
};
