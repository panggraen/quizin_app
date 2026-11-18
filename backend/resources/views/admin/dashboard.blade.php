<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard Admin | QUIZIN</title>

    <style>
        :root {
            --navy: #0C2054;
            --blue: #7198D0;
            --light-blue: #E6EEFC;
            --bg: #F3F6FB;
            --white: #FFFFFF;
            --text: #15254B;
            --muted: #748198;
            --border: #E6EBF3;
            --green: #66CA94;
            --yellow: #FFD45C;
            --red: #EC2528;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background: var(--bg);
            font-family: Arial, sans-serif;
            color: var(--text);
        }

        .layout { display: flex; min-height: 100vh; }

        .sidebar {
            width: 245px;
            flex-shrink: 0;
            background: linear-gradient(180deg, #0C2054, #102B5B);
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
            margin: 7px 0 0 3px;
            color: #BDD0EA;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 13px 16px;
            margin: 3px 0;
            border-radius: 9px;
            color: #E1E8F5;
            text-decoration: none;
            font-size: 14px;
        }

        .nav-item.active {
            background: #3473D4;
            font-weight: bold;
            color: white;
        }

        .nav-item.disabled {
            opacity: .7;
        }

        .nav-icon {
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        .sidebar-footer {
            margin-top: auto;
            border-top: 1px solid #ffffff30;
            padding-top: 17px;
        }

        .logout-side {
            border: none;
            background: transparent;
            color: white;
            padding: 12px 16px;
            cursor: pointer;
            font-size: 14px;
        }

        .main { flex: 1; min-width: 0; }

        .topbar {
            height: 72px;
            background: white;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 30px;
            gap: 20px;
        }

        .search {
            background: #F4F6FA;
            border: 1px solid #E2E7F0;
            padding: 13px 18px;
            border-radius: 10px;
            color: var(--muted);
            font-size: 13px;
            width: min(480px, 65%);
        }

        .admin-name {
            font-size: 13px;
            font-weight: bold;
            white-space: nowrap;
        }

        .content {
            padding: 24px;
            max-width: 1650px;
            margin: 0 auto;
        }

        .hero {
            min-height: 125px;
            background: linear-gradient(100deg, #E4EEFF, #C7DCFC);
            border-radius: 17px;
            padding: 27px 35px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            overflow: hidden;
            margin-bottom: 20px;
        }

        .hero h1 {
            font-size: 25px;
            margin: 0 0 12px;
            color: var(--navy);
        }

        .hero p {
            color: #536587;
            margin: 0;
            font-size: 14px;
        }

        .hero-art {
            font-size: 65px;
            letter-spacing: 10px;
            white-space: nowrap;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 15px;
            margin-bottom: 18px;
        }

        .card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 15px;
            box-shadow: 0 5px 18px #12275509;
            padding: 19px;
        }

        .stat-icon {
            width: 47px;
            height: 47px;
            display: grid;
            place-items: center;
            border-radius: 12px;
            background: #E3EDFF;
            font-size: 25px;
            margin-bottom: 12px;
        }

        .stat-title {
            font-size: 12px;
            color: #5B6983;
            margin-bottom: 8px;
        }

        .stat-number {
            font-size: 27px;
            font-weight: 800;
            color: var(--navy);
        }

        .stat-info {
            margin-top: 9px;
            font-size: 11px;
            color: #7E8BA0;
        }

        .analysis-grid {
            display: grid;
            grid-template-columns: 1.5fr 0.95fr 1fr;
            gap: 16px;
            margin-bottom: 18px;
        }

        .panel-heading {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            margin-bottom: 20px;
        }

        .panel-heading h2 {
            font-size: 16px;
            margin: 0 0 5px;
        }

        .panel-heading p {
            font-size: 12px;
            color: var(--muted);
            margin: 0;
        }

        .tag {
            background: #EDF3FF;
            color: #2452A4;
            padding: 8px 11px;
            border-radius: 8px;
            font-size: 11px;
            white-space: nowrap;
        }

        .chart-svg {
            display: block;
            width: 100%;
            height: auto;
        }

        .chart-axis {
            display: flex;
            justify-content: space-between;
            gap: 4px;
            color: var(--muted);
            font-size: 10px;
            margin-top: 4px;
        }

        .donut {
            width: 154px;
            height: 154px;
            border-radius: 50%;
            margin: 8px auto 18px;
            display: grid;
            place-items: center;
        }

        .donut-inner {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .donut-inner strong {
            font-size: 25px;
            color: var(--navy);
        }

        .donut-inner small {
            color: var(--muted);
            font-size: 11px;
        }

        .legend-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
            margin-top: 12px;
            gap: 8px;
        }

        .legend-label {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .dot {
            width: 11px;
            height: 11px;
            border-radius: 4px;
            display: inline-block;
        }

        .activity-item {
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
            font-size: 12px;
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-item strong {
            display: block;
            margin-bottom: 5px;
        }

        .activity-item small {
            color: var(--muted);
        }

        .table-wrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th {
            text-align: left;
            background: #F0F3F9;
            padding: 15px;
            color: #364767;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid var(--border);
        }

        tr:last-child td {
            border-bottom: none;
        }

        .muted { color: var(--muted); }

        .empty {
            text-align: center;
            padding: 28px;
            color: var(--muted);
        }

        @media(max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(3, 1fr);
            }
            .analysis-grid {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media(max-width: 850px) {
            .sidebar { width: 195px; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .analysis-grid { grid-template-columns: 1fr; }
            .hero-art { display: none; }
        }

        @media(max-width: 600px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; }
            .content { padding: 14px; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
            .hero h1 { font-size: 20px; }
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

        <a class="nav-item active"
           href="{{ route('admin.dashboard') }}">
            <span class="nav-icon">⌂</span> Dashboard
        </a>

        <a class="nav-item"
   href="{{ route('admin.categories.index') }}">
    <span class="nav-icon">▣</span> Kategori
</a>
        <span class="nav-item disabled">
            <span class="nav-icon">▤</span> Bidang
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">▦</span> Materi
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">▧</span> Modul Kuis
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">☷</span> Soal
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">♙</span> Pengguna
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">✦</span> Karakter
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">★</span> Badge
        </span>
        <span class="nav-item disabled">
            <span class="nav-icon">♛</span> Leaderboard
        </span>

        <div class="sidebar-footer">
            <form method="POST"
                  action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="logout-side">
                    ↪ Logout
                </button>
            </form>
        </div>
    </aside>

    <div class="main">
        <header class="topbar">
            <div class="search">
                ⌕ &nbsp; QUIZIN — Pusat Pengelolaan Konten
            </div>
            <div class="admin-name">
                👤 {{ auth('web')->user()->name }}
            </div>
        </header>

        <main class="content">
            <section class="hero">
                <div>
                    <h1>Selamat datang di Admin QUIZIN! 👋</h1>
                    <p>
                        Kelola materi, kuis, pengguna,
                        dan gamifikasi platform QUIZIN.
                    </p>
                </div>
                <div class="hero-art">📚 🎓</div>
            </section>

            <section class="stats-grid">
                @foreach ([
                    ['👥', 'Total Pengguna', $stats['users']],
                    ['📖', 'Total Materi', $stats['materials']],
                    ['📚', 'Modul Kuis', $stats['modules']],
                    ['🎮', 'Karakter', $stats['characters']],
                    ['🏅', 'Badge', $stats['badges']]
                ] as [$icon, $label, $value])
                    <div class="card">
                        <div class="stat-icon">{{ $icon }}</div>
                        <div class="stat-title">{{ $label }}</div>
                        <div class="stat-number">
                            {{ number_format($value, 0, ',', '.') }}
                        </div>
                        <div class="stat-info">
                            Data dari database QUIZIN
                        </div>
                    </div>
                @endforeach
            </section>

            <section class="analysis-grid">

                <div class="card">
                    <div class="panel-heading">
                        <div>
                            <h2>📊 Tren Pendaftaran Pengguna</h2>
                            <p>
                                Akun pengguna baru dalam 30 hari terakhir.
                            </p>
                        </div>
                        <span class="tag">30 Hari</span>
                    </div>

                    <svg class="chart-svg"
                         viewBox="0 0 800 210"
                         xmlns="http://www.w3.org/2000/svg">

                        <defs>
                            <linearGradient id="chartFill"
                                            x1="0" y1="0"
                                            x2="0" y2="1">
                                <stop offset="0%"
                                      stop-color="#7198D0"
                                      stop-opacity=".4"/>
                                <stop offset="100%"
                                      stop-color="#7198D0"
                                      stop-opacity=".03"/>
                            </linearGradient>
                        </defs>

                        <g stroke="#E5EBF4"
                           stroke-width="1">
                            <line x1="22" y1="40"
                                  x2="778" y2="40"/>
                            <line x1="22" y1="90"
                                  x2="778" y2="90"/>
                            <line x1="22" y1="140"
                                  x2="778" y2="140"/>
                            <line x1="22" y1="190"
                                  x2="778" y2="190"/>
                        </g>

                        <polygon
                            points="{{ $chart['area'] }}"
                            fill="url(#chartFill)"/>

                        <polyline
                            points="{{ $chart['line'] }}"
                            fill="none"
                            stroke="#3473D4"
                            stroke-width="3"
                            stroke-linecap="round"
                            stroke-linejoin="round"/>
                    </svg>

                    <div class="chart-axis">
                        @foreach ($chart['labels'] as $label)
                            <span>{{ $label }}</span>
                        @endforeach
                    </div>
                </div>

                <div class="card">
                    <div class="panel-heading">
                        <div>
                            <h2>🎯 Komposisi Konten</h2>
                            <p>Ringkasan data pembelajaran.</p>
                        </div>
                    </div>

                    <div class="donut"
                         style="background: {{ $donutBackground }};">
                        <div class="donut-inner">
                            <strong>{{ $contentTotal }}</strong>
                            <small>Total item</small>
                        </div>
                    </div>

                    <div class="legend-row">
                        <span class="legend-label">
                            <i class="dot"
                               style="background:#7198D0"></i>
                            Kategori
                        </span>
                        <strong>{{ $stats['categories'] }}</strong>
                    </div>

                    <div class="legend-row">
                        <span class="legend-label">
                            <i class="dot"
                               style="background:#66CA94"></i>
                            Materi
                        </span>
                        <strong>{{ $stats['materials'] }}</strong>
                    </div>

                    <div class="legend-row">
                        <span class="legend-label">
                            <i class="dot"
                               style="background:#FFD45C"></i>
                            Modul Kuis
                        </span>
                        <strong>{{ $stats['modules'] }}</strong>
                    </div>
                </div>

                <div class="card">
                    <div class="panel-heading">
                        <div>
                            <h2>⚡ Pengguna Terbaru</h2>
                            <p>Pendaftaran akun terbaru.</p>
                        </div>
                    </div>

                    @forelse ($recentUsers as $user)
                        <div class="activity-item">
                            <strong>
                                👤 {{ $user->name }}
                            </strong>
                            <small>
                                User ID {{ $user->id }}
                                ·
                                {{ $user->created_at
                                    ? \Carbon\Carbon::parse(
                                        $user->created_at
                                      )->format('d M Y')
                                    : 'Tanggal belum tersedia' }}
                            </small>
                        </div>
                    @empty
                        <div class="empty">
                            Belum ada pengguna.
                        </div>
                    @endforelse
                </div>
            </section>

            <section class="card">
                <div class="panel-heading">
                    <div>
                        <h2>📖 Materi Terbaru</h2>
                        <p>
                            Materi yang baru ditambahkan
                            ke dalam QUIZIN.
                        </p>
                    </div>
                    <span class="tag">Data Aktual</span>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Judul Materi</th>
                                <th>ID Materi</th>
                                <th>Terakhir Diperbarui</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($recentMaterials as $material)
                                <tr>
                                    <td>{{ $loop->iteration }}</td>
                                    <td>
                                        <strong>
                                            📖
                                            {{ $material->title
                                                ?? $material->name
                                                ?? ('Materi #' . $material->id) }}
                                        </strong>
                                    </td>
                                    <td>#{{ $material->id }}</td>
                                    <td class="muted">
                                        {{ !empty($material->updated_at)
                                            ? \Carbon\Carbon::parse(
                                                $material->updated_at
                                              )->format('d M Y, H:i')
                                            : '—' }}
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="4" class="empty">
                                        Belum ada materi.
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
