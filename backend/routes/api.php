
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\SubjectController;
use App\Http\Controllers\Api\MaterialController;
use App\Http\Controllers\Api\MaterialProgressController;
use App\Http\Controllers\Api\MaterialSummaryController;
use App\Http\Controllers\Api\DailyCheckinController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\QuizModuleController;
use App\Http\Controllers\Api\QuizAttemptController;
use App\Http\Controllers\Api\QuizAnswerController;
use App\Http\Controllers\Api\QuizResultController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\CharacterController;
use App\Http\Controllers\Api\BadgeController;
use App\Http\Controllers\Api\LeaderboardController;
/*
|--------------------------------------------------------------------------
| API Routes - QUIZIN
|--------------------------------------------------------------------------
*/

// 1. Autentikasi pengguna
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// 2. Endpoint yang membutuhkan login (Sanctum)
Route::middleware('auth:sanctum')->group(function () {

    // Akun pengguna
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Profil pengguna
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::patch('/profile', [ProfileController::class, 'update']);

    // Progres membaca materi dan hadiah XP
    Route::get(
        '/materials/{material}/progress',
        [MaterialProgressController::class, 'show']
    )->whereNumber('material');

    Route::post(
        '/materials/{material}/complete',
        [MaterialProgressController::class, 'complete']
    )->whereNumber('material');

    // Ringkasan progres materi
    Route::get(
        '/me/material-progress',
        [MaterialSummaryController::class, 'index']
    );

    // Check-in harian dan progres mingguan
    Route::get('/checkins/weekly', [DailyCheckinController::class, 'weekly']);
    Route::post('/checkins', [DailyCheckinController::class, 'store']);

    // Ringkasan halaman Home
    Route::get('/home', [HomeController::class, 'index']);

    // Daftar modul kuis berdasarkan materi
    Route::get(
        '/materials/{material}/quiz-modules',
        [QuizModuleController::class, 'index']
    )->whereNumber('material');

    // Memulai atau melanjutkan kuis
    Route::post(
        '/quiz-modules/{module}/start',
        [QuizAttemptController::class, 'start']
    )->whereNumber('module');

    // Menjawab soal kuis
    Route::post(
        '/quiz-attempts/{attempt}/answers',
        [QuizAnswerController::class, 'store']
    )->whereNumber('attempt');

    // Hasil dan pembahasan kuis
    Route::get(
        '/quiz-attempts/{attempt}/result',
        [QuizResultController::class, 'result']
    )->whereNumber('attempt');

    Route::get(
        '/quiz-attempts/{attempt}/review',
        [QuizResultController::class, 'review']
    )->whereNumber('attempt');

    // Membatalkan pengerjaan kuis
    Route::post(
        '/quiz-attempts/{attempt}/abandon',
        [QuizAttemptController::class, 'abandon']
    )->whereNumber('attempt');
    
    // Karakter pengguna
         Route::get('/characters', [CharacterController::class, 'index']);
        Route::post('/characters/{character}/purchase', [CharacterController::class, 'purchase'])
    ->whereNumber('character');
    Route::post('/characters/{character}/activate', [CharacterController::class, 'activate'])
    ->whereNumber('character'); 

        Route::patch(
    '/characters/{character}/activate',
    [CharacterController::class, 'activate']
)->whereNumber('character');

        // Daftar badge dan pencapaian pengguna
Route::get('/badges', [BadgeController::class, 'index']);
        // Peringkat pengguna berdasarkan total XP
Route::get('/leaderboard', [LeaderboardController::class, 'index']);
});

// 3. Konten pembelajaran publik

// Daftar kategori
Route::get('/categories', [CategoryController::class, 'index']);

// Daftar bidang berdasarkan kategori
Route::get(
    '/categories/{category}/subjects',
    [SubjectController::class, 'index']
)->whereNumber('category');

// Daftar materi berdasarkan bidang
Route::get(
    '/subjects/{subject}/materials',
    [MaterialController::class, 'bySubject']
)->whereNumber('subject');

// Semua materi yang dipublikasikan
Route::get('/materials', [MaterialController::class, 'index']);

// Detail materi
Route::get(
    '/materials/{material}',
    [MaterialController::class, 'show']
)->whereNumber('material');
