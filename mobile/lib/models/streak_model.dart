import 'package:quizin_app/models/json_utils.dart';

/// Ringkasan Daily Streak milik pengguna yang sedang login.
///
/// Semua nilai berasal dari server. Aplikasi tidak menghitung streak sendiri
/// dan tidak mengisi angka contoh.
///
/// Bentuk JSON (kontrak usulan, backend belum ada):
/// {
///   "current_streak": 3,
///   "today": "2026-11-18",                       // tanggal hari ini di Asia/Jakarta
///   "checked_dates": ["2026-11-16", "2026-11-17", "2026-11-18"]
/// }
/// `checked_dates` minimal berisi check-in pada minggu berjalan (Senin-Minggu).
class DailyStreakModel {
  const DailyStreakModel({
    required this.currentStreak,
    required this.today,
    required this.checkedDates,
  });

  /// Jumlah hari check-in berturut-turut sampai hari ini.
  final int currentStreak;

  /// Tanggal hari ini menurut server (Asia/Jakarta), tanpa jam, UTC.
  final DateTime today;

  /// Tanggal check-in (tanpa jam, UTC).
  final Set<DateTime> checkedDates;

  /// Senin pada minggu yang memuat [today].
  DateTime get weekStart => mondayOf(today);

  /// Tujuh tanggal minggu berjalan: Senin ... Minggu.
  List<DateTime> get weekDays =>
      [for (var i = 0; i < 7; i++) weekStart.add(Duration(days: i))];

  bool isChecked(DateTime day) => checkedDates.contains(day);

  /// Senin dari minggu yang memuat [day]. DateTime.weekday: Senin = 1.
  static DateTime mondayOf(DateTime day) =>
      day.subtract(Duration(days: day.weekday - DateTime.monday));

  /// "YYYY-MM-DD" (boleh diikuti jam) menjadi tanggal UTC. null jika tidak valid.
  static DateTime? parseDate(dynamic v) {
    if (v is! String) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(v);
    if (m == null) return null;
    return DateTime.utc(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  factory DailyStreakModel.fromJson(Map<String, dynamic> j) {
    final today = parseDate(j['today']);
    if (today == null) {
      throw const FormatException('Field "today" tidak valid');
    }

    final dates = <DateTime>{};
    final raw = j['checked_dates'];
    if (raw is List) {
      for (final item in raw) {
        final d = parseDate(item);
        if (d != null) dates.add(d);
      }
    }

    final streak = toInt(j['current_streak']);
    return DailyStreakModel(
      currentStreak: streak < 0 ? 0 : streak,
      today: today,
      checkedDates: dates,
    );
  }
}
