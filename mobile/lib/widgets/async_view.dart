import 'package:flutter/material.dart';
import 'package:quizin_app/core/network/api_exception.dart';
import 'package:quizin_app/widgets/state_widgets.dart';

/// Menampilkan loading, error (dengan tombol coba lagi), kosong, atau data.
/// Simpan [future] di State dan buat ulang saat ingin memuat ulang.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'Belum ada data.',
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snap.hasError) {
          return ErrorStateWidget(message: errorMessage(snap.error!), onRetry: onRetry);
        }
        final data = snap.data as T;
        if (isEmpty != null && isEmpty!(data)) return EmptyStateWidget(message: emptyMessage);
        return builder(context, data);
      },
    );
  }
}
