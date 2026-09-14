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
        return 'No Internet';
      case AppErrorKind.timeout:
        return 'Request Timed Out';
      case AppErrorKind.server:
        return 'Server Unreachable';
      case AppErrorKind.unknown:
      case null:
        return 'Something Went Wrong';
    }
  }

  String get _subtitle {
    switch (kind) {
      case AppErrorKind.network:
        return 'No Internet connection found.\nPlease try again.';
      case AppErrorKind.timeout:
        return 'The request took too long.\nPlease try again.';
      case AppErrorKind.server:
        return 'We couldn\'t reach the server.\nPlease try again.';
      case AppErrorKind.unknown:
      case null:
        return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            _icon,
            size: 72,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 20),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
