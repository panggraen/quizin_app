
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\SubjectController;
use App\Http\Controllers\Api\MaterialController;
use App\Http\Controllers\Api\MaterialProgressController;
use Illuminate\Support\Facades\Route;

// Autentikasi pengguna
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Endpoint yang membutuhkan token Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Progres membaca materi
    Route::get(
        '/materials/{material}/progress',
        [MaterialProgressController::class, 'show']
    )->whereNumber('material');

    Route::post(
        '/materials/{material}/complete',
        [MaterialProgressController::class, 'complete']
    )->whereNumber('material');
});

// Konten pembelajaran publik
Route::get('/categories', [CategoryController::class, 'index']);

Route::get(
    '/categories/{category}/subjects',
    [SubjectController::class, 'index']
)->whereNumber('category');

Route::get(
    '/subjects/{subject}/materials',
    [MaterialController::class, 'bySubject']
)->whereNumber('subject');

Route::get('/materials', [MaterialController::class, 'index']);

Route::get(
    '/materials/{material}',
    [MaterialController::class, 'show']
)->whereNumber('material');
