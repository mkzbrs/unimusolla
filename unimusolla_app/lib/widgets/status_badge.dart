import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'approved' || 'available' => Colors.green,
      'rejected' || 'unavailable' => Colors.red,
      _ => Colors.orange,
    };
    return Chip(
      label: Text(status.toUpperCase()),
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        color: color.shade900,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      backgroundColor: color.shade50,
      side: BorderSide(color: color.shade200),
    );
  }
}
