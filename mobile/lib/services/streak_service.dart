import 'package:quizin_app/models/streak_model.dart';

/// Kontrak (USULAN, BELUM ADA DI BACKEND): POST /api/daily-checkin
///
/// Satu panggilan melakukan dua hal di server:
///  1. mencatat check-in hari ini (Asia/Jakarta) untuk pengguna yang login,
///     paling banyak satu baris per pengguna per hari (idempoten), lalu
///  2. mengembalikan ringkasan streak (lihat [DailyStreakModel.fromJson]).
///
/// Membuka aplikasi berkali-kali dalam sehari tidak menambah streak.
/// Detail kebutuhan backend: DAILY_STREAK_BACKEND_NEEDED.md.
abstract class StreakService {
  Future<DailyStreakModel> checkIn();
}
