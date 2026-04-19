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
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Paste a video link…',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 18,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: enabled ? onPastePressed : null,
            icon: const Icon(Icons.paste),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
