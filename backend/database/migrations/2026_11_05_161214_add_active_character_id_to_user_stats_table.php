
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_stats', function (Blueprint $table) {
            $table->foreignId('active_character_id')
                ->nullable()
                ->constrained('characters')
                ->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('user_stats', function (Blueprint $table) {
            $table->dropForeign(['active_character_id']);
            $table->dropColumn('active_character_id');
        });
    }
};
