import 'package:flutter/material.dart';

import '../data/profile_store.dart';
import '../../../core/theme/viril_colors.dart';
import 'profile_frame.dart';

/// Shared avatar renderer used by the Home, Profile and Progress headers.
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
    final hasRemoteImage = profile.accountAvatarUrl.startsWith('https://');
    final content = hasRemoteImage
        ? ClipOval(
            child: Image.network(
              profile.accountAvatarUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackIcon(),
            ),
          )
        : _fallbackIcon();

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

  Widget _fallbackIcon() => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: profile.hasAvatarImage
              ? Icon(profile.avatarIcon, color: VirilColors.gold, size: iconSize ?? size * .48)
              : const SizedBox.shrink(),
        ),
      );
}