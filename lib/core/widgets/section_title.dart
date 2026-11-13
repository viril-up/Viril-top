import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -.5)),
      if (subtitle != null) ...[
        const SizedBox(height: 5),
        Text(subtitle!, style: const TextStyle(color: VirilColors.muted, fontSize: 13)),
      ],
    ]),
  );
}
