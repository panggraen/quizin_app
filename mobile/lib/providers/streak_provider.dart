import 'package:flutter/foundation.dart';
import 'package:quizin_app/models/streak_model.dart';
import 'package:quizin_app/services/streak_service.dart';

enum StreakStatus {
  /// Sedang menunggu jawaban server.
  loading,

  /// Data streak asli dari server tersedia di [StreakProvider.data].
  ready,

  /// Belum ada layanan streak (backend belum dibuat / belum disambungkan).
  unavailable,

  /// Layanan ada, tetapi permintaan gagal dan belum ada data sebelumnya.
  error,
}

/// Menyimpan status Daily Streak untuk layar Beranda.
///
/// Tanpa [StreakService] status selalu [StreakStatus.unavailable] dan [data]
/// tetap null: angka streak TIDAK PERNAH dikarang di sisi aplikasi.
class StreakProvider extends ChangeNotifier {
  StreakProvider([this._service])
      : status = _service == null
            ? StreakStatus.unavailable
            : StreakStatus.loading;

  final StreakService? _service;

  StreakStatus status;
  DailyStreakModel? data;
  bool _inFlight = false;

  bool get isAvailable => _service != null;

  /// Catat check-in hari ini lalu muat ulang streak. Aman dipanggil berulang:
  /// panggilan yang tumpang tindih diabaikan, dan server yang menjamin satu
  /// check-in per hari.
  Future<void> checkIn() async {
    final service = _service;
    if (service == null || _inFlight) return;
    _inFlight = true;

    if (data == null) {
      status = StreakStatus.loading;
      notifyListeners();
    }

    try {
      data = await service.checkIn();
      status = StreakStatus.ready;
    } catch (_) {
      // Jika sudah pernah berhasil, tetap tampilkan data terakhir yang asli.
      status = data == null ? StreakStatus.error : StreakStatus.ready;
    } finally {
      _inFlight = false;
    }
    notifyListeners();
  }

  /// Dipanggil saat logout agar data pengguna lama tidak terbawa.
  void clear() {
    data = null;
    status = _service == null ? StreakStatus.unavailable : StreakStatus.loading;
    notifyListeners();
  }
}
