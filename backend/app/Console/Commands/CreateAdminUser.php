<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class CreateAdminUser extends Command
{
    protected $signature = 'admin:create';

    protected $description = 'Membuat akun admin QUIZIN';

    public function handle(): int
    {
        $name = trim((string) $this->ask(
            'Nama admin',
            'Admin QUIZIN'
        ));

        $email = strtolower(trim((string) $this->ask(
            'Email admin'
        )));

        $password = (string) $this->secret(
            'Password admin (minimal 12 karakter)'
        );

        $confirmation = (string) $this->secret(
            'Ulangi password admin'
        );

        $validator = Validator::make(
            [
                'name' => $name,
                'email' => $email,
                'password' => $password,
            ],
            [
                'name' => ['required', 'string', 'max:255'],
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    'unique:users,email',
                ],
                'password' => [
                    'required',
                    'string',
                    'min:12',
                ],
            ]
        );

        if ($validator->fails()) {
            $this->error(
                $validator->errors()->first()
            );

            return self::FAILURE;
        }

        if (!hash_equals($password, $confirmation)) {
            $this->error(
                'Konfirmasi password tidak sesuai.'
            );

            return self::FAILURE;
        }

        DB::table('users')->insert([
            'name' => $name,
            'email' => $email,
            'password' => Hash::make($password),
            'role' => 'admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->info(
            'Akun admin QUIZIN berhasil dibuat.'
        );

        return self::SUCCESS;
    }
}
