
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1">
    <title>Manajemen Kategori | QUIZIN</title>

    <style>
        :root {
            --navy: #0C2054;
            --blue: #3473D4;
            --background: #F3F6FB;
            --white: #FFFFFF;
            --text: #15254B;
            --muted: #748198;
            --border: #E6EBF3;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: var(--background);
            color: var(--text);
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 245px;
            flex-shrink: 0;
            background: linear-gradient(
                180deg, #0C2054, #102B5B
            );
            color: white;
            padding: 28px 14px;
            display: flex;
            flex-direction: column;
        }

        .brand {
            padding: 0 14px 25px;
            border-bottom: 1px solid #ffffff28;
            margin-bottom: 22px;
        }

        .brand strong {
            font-size: 26px;
            letter-spacing: 1px;
        }

        .brand small {
            display: block;
            margin-top: 7px;
            color: #BDD0EA;
        }

        .nav-item {
            display: block;
            padding: 13px 16px;
            margin: 3px 0;
            color: #E1E8F5;
            text-decoration: none;
            border-radius: 9px;
            font-size: 14px;
        }

        .nav-item.active {
            background: var(--blue);
            color: white;
            font-weight: bold;
        }

        .nav-item.disabled { opacity: .65; }

        .sidebar-footer {
            margin-top: auto;
            border-top: 1px solid #ffffff30;
            padding-top: 15px;
        }

        .logout {
            background: transparent;
            border: none;
            padding: 12px 16px;
            color: white;
            cursor: pointer;
            font-size: 14px;
        }

        .main {
            flex: 1;
            min-width: 0;
        }

        .topbar {
            height: 72px;
            background: white;
            border-bottom: 1px solid var(--border);
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .topbar strong { color: var(--navy); }

        .content {
    padding: 24px;
    max-width: 1650px;
    margin: 0 auto;
}

        .page-heading {
            margin-bottom: 25px;
        }

        h1 {
            color: var(--navy);
            font-size: 26px;
            margin: 0 0 10px;
        }

        .description {
            color: var(--muted);
            font-size: 14px;
            line-height: 1.6;
            margin: 0;
        }

        .summary {
            background: #E6EEFC;
            border-radius: 13px;
            padding: 20px 24px;
            margin-bottom: 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .summary strong {
            color: var(--navy);
            font-size: 29px;
        }

        .summary span {
            color: #536587;
            font-size: 13px;
        }

        .card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 15px;
            box-shadow: 0 5px 18px #12275509;
            overflow: hidden;
        }

        .card-header {
            padding: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }

        .card-header h2 {
            margin: 0 0 6px;
            font-size: 17px;
            color: var(--navy);
        }

        .card-header p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
        }

        .table-wrap { overflow-x: auto; }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th {
            background: #F0F3F9;
            text-align: left;
            padding: 17px;
            color: #364767;
        }

        td {
            padding: 18px 17px;
            border-bottom: 1px solid var(--border);
        }

        tr:last-child td {
            border-bottom: none;
        }

        .category-name {
            font-weight: bold;
            color: var(--navy);
        }

        .slug {
            color: var(--muted);
            font-family: monospace;
        }

        .status {
            display: inline-block;
            border-radius: 20px;
            padding: 7px 11px;
            font-size: 11px;
            font-weight: bold;
        }

        .active {
            background: #E0F8EB;
            color: #228455;
        }

        .inactive {
            background: #FDE8E8;
            color: #C63B3B;
        }

        .empty {
            text-align: center;
            padding: 30px;
            color: var(--muted);
        }

        @media(max-width: 700px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; }
            .content { padding: 16px; }
            .topbar { padding: 0 16px; }
        }
    </style>
</head>

<body>
<div class="layout">

    <aside class="sidebar">
        <div class="brand">
            <strong>🎓 QUIZIN</strong>
            <small>Admin Panel</small>
        </div>

        <a href="{{ route('admin.dashboard') }}"
           class="nav-item">
            ⌂ &nbsp; Dashboard
        </a>

        <a href="{{ route('admin.categories.index') }}"
           class="nav-item active">
            ▣ &nbsp; Kategori
        </a>

        <span class="nav-item disabled">▤ &nbsp; Bidang</span>
        <span class="nav-item disabled">▦ &nbsp; Materi</span>
        <span class="nav-item disabled">▧ &nbsp; Modul Kuis</span>
        <span class="nav-item disabled">☷ &nbsp; Soal</span>
        <span class="nav-item disabled">♙ &nbsp; Pengguna</span>
        <span class="nav-item disabled">✦ &nbsp; Karakter</span>
        <span class="nav-item disabled">★ &nbsp; Badge</span>
        <span class="nav-item disabled">♛ &nbsp; Leaderboard</span>

        <div class="sidebar-footer">
            <form method="POST"
                  action="{{ route('admin.logout') }}">
                @csrf
                <button class="logout" type="submit">
                    ↪ Logout
                </button>
            </form>
        </div>
    </aside>

    <div class="main">

        <header class="topbar">
            <strong>Manajemen Kategori</strong>
            <span>
                👤 {{ auth('web')->user()->name }}
            </span>
        </header>

        <main class="content">

            <div class="page-heading">
                <h1>Manajemen Kategori</h1>
                <p class="description">
                    Kelola kategori pembelajaran QUIZIN
                    seperti IPA, Sejarah, dan Matematika.
                </p>
            </div>

            <div class="summary">
                <div>
                    <span>Total kategori terdaftar</span>
                </div>
                <strong>{{ $categories->count() }}</strong>
            </div>

            <section class="card">

                <div class="card-header">
                    <div>
                        <h2>Daftar Kategori</h2>
                        <p>
                            Kategori yang tersimpan
                            pada database QUIZIN.
                        </p>
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Nama Kategori</th>
                                <th>Slug</th>
                                <th>Jumlah Bidang</th>
                                <th>Urutan</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>
                            @forelse ($categories as $category)
                                <tr>
                                    <td>{{ $loop->iteration }}</td>

                                    <td class="category-name">
                                        {{ $category->name }}
                                    </td>

                                    <td class="slug">
                                        {{ $category->slug }}
                                    </td>

                                    <td>
                                        {{ $category->subjects_count }}
                                    </td>

                                    <td>
                                        {{ $category->sort_order }}
                                    </td>

                                    <td>
                                        @if ($category->is_active)
                                            <span class="status active">
                                                Aktif
                                            </span>
                                        @else
                                            <span class="status inactive">
                                                Nonaktif
                                            </span>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="empty">
                                        Belum ada kategori.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

            </section>

        </main>
    </div>
</div>
</body>
</html>
