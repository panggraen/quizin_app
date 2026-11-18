<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Admin - QUIZIN</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6fb;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
        }
        .card {
            background: white;
            padding: 32px;
            width: 350px;
            max-width: 85%;
            border-radius: 16px;
            box-shadow: 0 8px 30px #00000012;
        }
        h1 { text-align: center; color: #333; }
        p { text-align: center; color: #777; }
        label { display: block; margin-top: 16px; }
        input {
            width: 100%;
            padding: 12px;
            box-sizing: border-box;
            margin-top: 6px;
            border: 1px solid #ccc;
            border-radius: 8px;
        }
        button {
            width: 100%;
            padding: 12px;
            margin-top: 24px;
            background: #6658d3;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        .error { color: #d33; font-size: 13px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>QUIZIN</h1>
        <p>Login Panel Admin</p>

        <form method="POST" action="{{ route('admin.login.submit') }}">
            @csrf

            <label>Email Admin</label>
            <input type="email" name="email"
                   value="{{ old('email') }}" required>

            @error('email')
                <div class="error">{{ $message }}</div>
            @enderror

            <label>Password</label>
            <input type="password" name="password" required>

            <button type="submit">Masuk sebagai Admin</button>
        </form>
    </div>
</body>
</html>
