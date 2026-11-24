import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/models/streak_model.dart';
import 'package:quizin_app/providers/streak_provider.dart';

/// Daily Streak di Beranda: SATU wadah horizontal yang kompak.
///
/// Baris atas : "Daily Streak" di kiri, fire.png + "3 Hari" di kanan.
/// Baris bawah: pelacak minggu berjalan Sen-Min, tujuh lingkaran dalam satu baris.
///
/// Murni tampilan: tidak ada tombol check-in (check-in otomatis saat aplikasi
/// dibuka) dan tidak ada hadiah harian.
class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({
    super.key,
    required this.status,
    required this.data,
    required this.fallbackToday,
    this.onRetry,
  });

  /// Status pemuatan data streak.
  final StreakStatus status;

  /// Data asli dari server. null = belum ada (memuat / tidak tersedia / gagal).
  final DailyStreakModel? data;

  /// Tanggal hari ini (Asia/Jakarta) dari jam perangkat. Hanya dipakai untuk
  /// menandai hari ini saat [data] belum ada; tidak pernah dianggap check-in.
  final DateTime fallbackToday;

  /// Dipanggil saat kartu diketuk pada status [StreakStatus.error].
  final VoidCallback? onRetry;

  static const List<String> dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const String fireAsset = 'assets/fire.png';
  static const double _maxCircle = 30;

  /// Keadaan tiap hari dalam minggu berjalan. Tanpa data asli, hanya "hari ini"
  /// yang ditandai; hari lain netral (tidak diklaim terlewat atau tercentang).
  static List<StreakDayState> dayStates(DailyStreakModel? data, DateTime fallbackToday) {
    final today = data?.today ?? fallbackToday;
    final monday = DailyStreakModel.mondayOf(today);

    return [
      for (var i = 0; i < 7; i++)
        () {
          final day = monday.add(Duration(days: i));
          if (data != null && data.isChecked(day)) return StreakDayState.checked;
          if (day == today) return StreakDayState.todayPending;
          if (data != null && day.isBefore(today)) return StreakDayState.missed;
          return StreakDayState.future;
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final d = data;
    final ready = status == StreakStatus.ready && d != null;
    final states = dayStates(d, fallbackToday);
    final countText = ready ? '${d!.currentStreak} Hari' : '– Hari';

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: dark ? Colors.white12 : const Color(0xFFD9E5F8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily Streak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text(context),
                  ),
                ),
              ),
              Image.asset(
                fireAsset,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                // Hanya jika fire.png belum ditaruh di assets/. Bukan emoji.
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_fire_department,
                  size: 22,
                  color: Color(0xFFFF7A1A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                countText,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ready
                      ? (dark ? Colors.white : AppColors.primary)
                      : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _weekRow(context, states),
          if (!ready && status != StreakStatus.loading) ...[
            const SizedBox(height: 6),
            Text(
              status == StreakStatus.error
                  ? 'Streak gagal dimuat. Ketuk untuk coba lagi.'
                  : 'Data streak belum tersedia.',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );

    final canRetry = status == StreakStatus.error && onRetry != null;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: _semanticsLabel(ready, states),
      onTap: canRetry ? onRetry : null,
      child: canRetry
          ? InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              onTap: onRetry,
              child: card,
            )
          : card,
    );
  }

  /// Tujuh kolom sama lebar; ukuran lingkaran mengikuti lebar agar selalu muat
  /// satu baris, termasuk di HP sempit dan saat teks diperbesar.
  Widget _weekRow(BuildContext context, List<StreakDayState> states) {
    return LayoutBuilder(
      builder: (context, c) {
        final column = c.maxWidth / 7;
        final circle = (column - 6).clamp(18.0, _maxCircle).toDouble();

        return Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: column,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dayLabels[i],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: states[i] == StreakDayState.todayPending
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: states[i] == StreakDayState.todayPending
                                ? (AppColors.isDark(context)
                                    ? Colors.white
                                    : AppColors.primary)
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _DayCircle(state: states[i], size: circle),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _semanticsLabel(bool ready, List<StreakDayState> states) {
    final b = StringBuffer('Daily Streak. ');
    b.write(ready ? '${data!.currentStreak} hari berturut-turut. ' : 'Data belum tersedia. ');
    for (var i = 0; i < 7; i++) {
      final s = states[i];
      final text = s == StreakDayState.checked
          ? 'sudah check-in'
          : s == StreakDayState.todayPending
              ? 'hari ini, belum check-in'
              : s == StreakDayState.missed
                  ? 'terlewat'
                  : 'belum';
      b.write('${dayLabels[i]} $text. ');
    }
    return b.toString();
  }
}

/// Keadaan satu hari pada pelacak mingguan.
enum StreakDayState {
  /// Sudah check-in: lingkaran biru penuh + centang putih.
  checked,

  /// Hari ini, belum tercatat: garis tepi biru.
  todayPending,

  /// Sudah lewat tanpa check-in: lingkaran abu-abu tanpa centang.
  missed,

  /// Belum tiba (atau belum diketahui): lingkaran abu-abu muda.
  future,
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.state, required this.size});

  final StreakDayState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    switch (state) {
      case StreakDayState.checked:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: size * 0.62, color: Colors.white),
        );
      case StreakDayState.todayPending:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: dark ? Colors.white : AppColors.primary,
              width: 2,
            ),
          ),
        );
      case StreakDayState.missed:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: dark ? Colors.white38 : const Color(0xFFBFC7D8),
            shape: BoxShape.circle,
          ),
        );
      case StreakDayState.future:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: dark ? Colors.white12 : const Color(0xFFE3E8F1),
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
