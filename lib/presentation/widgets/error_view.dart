import 'package:flutter/material.dart';
import 'package:productcatalog/data/app_exception.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final AppErrorKind? kind;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.kind,
  });

  IconData get _icon {
    switch (kind) {
      case AppErrorKind.network:
        return Icons.wifi_off_rounded;
      case AppErrorKind.timeout:
        return Icons.hourglass_disabled_rounded;
      case AppErrorKind.server:
        return Icons.cloud_off_rounded;
      case AppErrorKind.unknown:
      case null:
        return Icons.error_outline_rounded;
    }
  }

  String get _title {
    switch (kind) {
      case AppErrorKind.network:
        return 'No internet connection';
      case AppErrorKind.timeout:
        return 'Request timed out';
      case AppErrorKind.server:
        return 'Server unreachable';
      case AppErrorKind.unknown:
      case null:
        return 'Something went wrong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 48, color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 20),
            Text(
              _title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
