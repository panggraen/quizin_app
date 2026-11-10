/// Error yang pesannya aman ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

String errorMessage(Object e) =>
    e is ApiException ? e.message : 'Terjadi kesalahan. Coba lagi.';
