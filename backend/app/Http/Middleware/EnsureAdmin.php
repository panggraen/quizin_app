<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdmin
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {
        // Pastikan pengguna login dan memiliki role admin.
        if (
            !$request->user() ||
            $request->user()->role !== 'admin'
        ) {
            abort(
                403,
                'Akses hanya diperbolehkan untuk admin QUIZIN.'
            );
        }

        return $next($request);
    }
}
