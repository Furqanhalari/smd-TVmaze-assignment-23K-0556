import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Search text field with a clear (X) button that appears once there is text.
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search TV shows...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
        // Rebuilds only the suffix icon whenever the text changes.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                  onPressed: onClear,
                ),
        ),
      ),
    );
  }
}
