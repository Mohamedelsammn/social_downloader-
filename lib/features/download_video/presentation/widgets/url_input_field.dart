import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class UrlInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPastePressed;
  final bool enabled;

  const UrlInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onPastePressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, right: 8),
            child: Icon(Icons.link,
                color: AppColors.onSurfaceVariant, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                hintText: 'Paste video URL here',
                hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: enabled ? onPastePressed : null,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.onSurface,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Paste',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
