import 'package:flutter/material.dart';
import 'package:quizin_app/core/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.navy));
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
}

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
              ],
            ],
          ),
        ),
      );
}
