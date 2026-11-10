/// Satu-satunya tempat konfigurasi alamat API.
/// Saat ini aplikasi memakai MockBackend (data contoh, lihat app.dart).
/// Saat backend Laravel siap, buat kelas Api*Service lalu ganti di app.dart.
class AppConfig {
  /// Emulator Android: http://10.0.2.2:8000/api
  /// HP nyata: http://IP-LAPTOP:8000/api (satu Wi-Fi dengan laptop backend)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
}
