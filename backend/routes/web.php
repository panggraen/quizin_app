<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\CategoryController;
// Halaman utama Laravel
Route::get('/', function () {
    return view('welcome');
});

// Halaman Login Admin
Route::get('/admin/login', [
    AdminAuthController::class, 'showLogin'
])->name('admin.login');

// Proses Login Admin
Route::post('/admin/login', [
    AdminAuthController::class, 'login'
])->middleware('throttle:5,1')->name('admin.login.submit');

// Halaman khusus Admin
Route::prefix('admin')
    ->name('admin.')
    ->middleware(['auth:web', 'admin'])
    ->group(function () {

        // Dashboard Admin
        Route::get('/dashboard', [
            DashboardController::class, 'index'
        ])->name('dashboard');

        // Logout Admin
        Route::post('/logout', [
            AdminAuthController::class, 'logout'
        ])->name('logout');
        // Manajemen Kategori
        Route::get('/categories', [
            CategoryController::class, 'index'
        ])->name('categories.index');
    });
