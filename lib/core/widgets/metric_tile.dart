import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';
import 'glass_card.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.value, required this.label, this.icon});
  final String value, label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => GlassCard(padding: const EdgeInsets.all(16), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (icon != null) Icon(icon, color: VirilColors.gold, size: 19),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
    ],
  ));
}
