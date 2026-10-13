import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/html_utils.dart';
import '../../../data/models/show.dart';

/// The plain-text summary and a "Quick Info" card.
class OverviewTab extends StatelessWidget {
  final Show show;

  const OverviewTab({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    final summary = HtmlUtils.strip(show.summary);
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Summary', style: titleStyle),
        const SizedBox(height: 8),
        Text(
          summary.isEmpty ? 'No summary available.' : summary,
          style: const TextStyle(height: 1.5),
        ),
        const SizedBox(height: 24),
        Text('Quick Info', style: titleStyle),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _InfoRow(label: 'Status', value: show.status),
                _InfoRow(label: 'Network', value: show.network),
                _InfoRow(label: 'Language', value: show.language),
                _InfoRow(label: 'Premiered', value: show.premiered),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One "label ... value" line. A null value shows "Unknown".
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? 'Unknown',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
