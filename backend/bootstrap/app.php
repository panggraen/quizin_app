
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use App\Http\Middleware\EnsureAdmin;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Tidak mengarahkan pengguna API ke halaman login web
        $middleware->redirectGuestsTo(function (Request $request) {
            return null;
        });

        // Menambahkan middleware EnsureAdmin untuk rute API
        $middleware->alias([
            'admin' => EnsureAdmin::class,
        ]);
        $middleware->redirectGuestsTo('/admin/login');

    })
    ->withExceptions(function (Exceptions $exceptions): void {

        // Semua error API dikembalikan dalam format JSON
        $exceptions->shouldRenderJsonWhen(function (Request $request, $e) {
            return $request->is('api/*') || $request->expectsJson();
        });

        // Token tidak ada atau tidak valid menghasilkan HTTP 401
        $exceptions->render(function (
            AuthenticationException $e,
            Request $request
        ) {
            if ($request->is('api/*')) {
                return response()->json([
                    'message' => 'Unauthenticated.',
                ], 401);
            }

            return null;
        });
    })
    ->create();
