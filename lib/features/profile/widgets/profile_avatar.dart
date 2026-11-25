import 'package:flutter/material.dart';

import '../data/profile_store.dart';
import 'profile_frame.dart';

/// Shared avatar renderer used by the Home, Profile and Progress headers.
/// A missing avatar image keeps the circular avatar surface visible; only its
/// inner symbol is omitted. The selected frame is always applied independently.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    required this.size,
    this.iconSize,
  });

  final ProfileStore profile;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final content = profile.hasAvatarImage
        ? Icon(profile.avatarIcon, color: const Color(0xFFFFD27A), size: iconSize ?? size * .48)
        : const SizedBox.shrink();

    if (profile.hasFrame) {
      return ProfileFrame(frameIndex: profile.frameIndex, size: size, child: content);
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF111720),
        ),
        child: Center(child: content),
      ),
    );
  }
}
