<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\DashboardController;
use Illuminate\Support\Facades\Route;

// Halaman utama Laravel
Route::get('/', function () {
    return view('welcome');
});

// Halaman Login Admin
Route::get('/admin/login', [
    AdminAuthController::class, 'showLogin',
])->name('admin.login');

// Proses Login Admin
Route::post('/admin/login', [
    AdminAuthController::class, 'login',
])->middleware('throttle:5,1')->name('admin.login.submit');

// Halaman khusus Admin
Route::prefix('admin')
    ->name('admin.')
    ->middleware(['auth:web', 'admin'])
    ->group(function () {

        // Dashboard Admin
        Route::get('/dashboard', [
            DashboardController::class, 'index',
        ])->name('dashboard');

        // Logout Admin
        Route::post('/logout', [
            AdminAuthController::class, 'logout',
        ])->name('logout');

        // Manajemen Kategori
        Route::get('/categories', [
            CategoryController::class, 'index',
        ])->name('categories.index');

        Route::get('/categories/create', [
            CategoryController::class, 'create',
        ])->name('categories.create');

        Route::post('/categories', [
            CategoryController::class, 'store',
        ])->name('categories.store');

        Route::get('/categories/{category}/edit', [
            CategoryController::class, 'edit',
        ])->name('categories.edit');

        Route::put('/categories/{category}', [
            CategoryController::class, 'update',
        ])->name('categories.update');

        Route::delete('/categories/{category}', [
            CategoryController::class, 'destroy',
        ])->name('categories.destroy');
    });
