/// Zona waktu aplikasi untuk semua perhitungan "hari": Asia/Jakarta (WIB).
///
/// WIB = UTC+7 tetap, Indonesia tidak memakai DST, jadi offset tetap sudah
/// benar tanpa paket tambahan. Backend harus memakai zona yang sama
/// (lihat DAILY_STREAK_BACKEND_NEEDED.md).
class AppTime {
  static const String zoneName = 'Asia/Jakarta';
  static const Duration jakartaOffset = Duration(hours: 7);

  /// Tanggal hari ini di Jakarta (tanpa jam), disimpan sebagai DateTime UTC
  /// supaya perbandingan tanggal tidak terpengaruh zona waktu perangkat.
  static DateTime todayJakarta([DateTime? now]) {
    final j = (now ?? DateTime.now()).toUtc().add(jakartaOffset);
    return DateTime.utc(j.year, j.month, j.day);
  }
}
