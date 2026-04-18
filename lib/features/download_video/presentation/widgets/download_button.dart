import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DownloadButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  const DownloadButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effective = enabled && !loading ? onPressed : null;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: effective == null ? null : AppColors.primaryGradient,
          color: effective == null
              ? AppColors.surfaceContainerHigh
              : null,
          borderRadius: BorderRadius.circular(32),
          boxShadow: effective == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: effective,
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_rounded,
                    color: effective == null
                        ? AppColors.onSurfaceVariant
                        : AppColors.onPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: effective == null
                          ? AppColors.onSurfaceVariant
                          : AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
