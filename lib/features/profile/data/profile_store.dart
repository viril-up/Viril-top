import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/services/progress_sync_service.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _nameKey = 'viril.profile.name.v1';
  static const _bioKey = 'viril.profile.bio.v1';
  static const _avatarKey = 'viril.profile.avatar.v1';
  static const _frameKey = 'viril.profile.frame.v1';
  static const _userIdKey = 'viril.profile.demo_user_id.v1';

  String _name = 'Путник';
  String _bio = 'Мой путь начинается сегодня.';
  String _userId = '';
  String _accountEmail = '';
  String _accountName = '';
  String _accountAvatarUrl = '';
  String _accountPublicId = '';
  int _avatarIndex = 0;
  int _frameIndex = 0;
  bool _ready = false;
  StreamSubscription<AuthState>? _authSubscription;

  String get name => _name == 'Путник' && _accountName.isNotEmpty ? _accountName : _name;
  String get bio => _bio;
  String get userId => isSignedIn ? _accountPublicId : _userId;
  String get accountEmail => _accountEmail;
  String get accountName => _accountName;
  String get accountAvatarUrl => _accountAvatarUrl;
  bool get isSignedIn => _accountEmail.isNotEmpty || _accountName.isNotEmpty || _accountPublicId.isNotEmpty;
  int get avatarIndex => _avatarIndex;
  int get frameIndex => _frameIndex;
  bool get isReady => _ready;
  bool get hasAvatar => true;
  bool get hasAvatarImage => _avatarIndex >= 0;
  bool get hasFrame => _frameIndex >= 0;
  IconData get avatarIcon => const <IconData>[
    Icons.psychology_rounded, Icons.auto_awesome_rounded, Icons.fitness_center_rounded,
    Icons.self_improvement_rounded, Icons.menu_book_rounded, Icons.school_rounded,
    Icons.lightbulb_rounded, Icons.explore_rounded, Icons.shield_rounded,
    Icons.bolt_rounded, Icons.favorite_rounded, Icons.spa_rounded,
    Icons.track_changes_rounded, Icons.military_tech_rounded, Icons.waves_rounded,
    Icons.rocket_launch_rounded, Icons.nights_stay_rounded, Icons.public_rounded,
    Icons.diamond_rounded, Icons.emoji_events_rounded,
  ][_avatarIndex.clamp(0, 19).toInt()];

  Future<void> initialize() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? _name;
    _bio = prefs.getString(_bioKey) ?? _bio;
    _avatarIndex = prefs.getInt(_avatarKey) ?? 0;
    _frameIndex = prefs.getInt(_frameKey) ?? 0;
    _userId = prefs.getString(_userIdKey) ?? _generateDemoId();
    await prefs.setString(_userIdKey, _userId);
    _ready = true;

    if (SupabaseService.isInitialized) {
      final client = SupabaseService.client;
      await _applyAuthUser(client.auth.currentUser);
      _authSubscription ??= client.auth.onAuthStateChange.listen((state) {
        _applyAuthUser(state.session?.user);
      });
    }
    notifyListeners();
  }

  Future<void> _applyAuthUser(User? user) async {
    if (user == null) {
      ProgressSyncService.instance.onSignedOut();
      _accountEmail = '';
      _accountName = '';
      _accountAvatarUrl = '';
      _accountPublicId = '';
      notifyListeners();
      return;
    }

    _accountEmail = user.email ?? '';
    _accountPublicId = '';
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    _accountName = (metadata['full_name'] ?? metadata['name'] ?? '').toString();
    _accountAvatarUrl = (metadata['avatar_url'] ?? metadata['picture'] ?? '').toString();

    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select('public_id, full_name, avatar_url')
          .eq('user_id', user.id)
          .maybeSingle();
      if (row != null) {
        final publicId = row['public_id']?.toString() ?? '';
        if (publicId.isNotEmpty) _accountPublicId = publicId.padLeft(4, '0');
        final fullName = row['full_name']?.toString() ?? '';
        final avatar = row['avatar_url']?.toString() ?? '';
        if (fullName.isNotEmpty) _accountName = fullName;
        if (avatar.isNotEmpty) _accountAvatarUrl = avatar;
      }
    } catch (_) {
      // OAuth metadata remains available if profile row access is not yet configured.
    }
    notifyListeners();
    // Progress is synchronized only after Supabase has supplied a verified user.
    await ProgressSyncService.instance.syncForCurrentUser();
  }

  String _generateDemoId() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> signOut() async {
    if (SupabaseService.isInitialized) {
      await SupabaseService.client.auth.signOut();
    }
  }

  Future<void> updateProfile({required String name, required String bio, required int avatarIndex, int? frameIndex}) async {
    final cleanName = name.trim();
    _name = cleanName.isEmpty ? 'Путник' : cleanName;
    _bio = bio.trim();
    _avatarIndex = avatarIndex.clamp(-1, 19).toInt();
    if (frameIndex != null) _frameIndex = frameIndex.clamp(-1, 7).toInt();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_bioKey, _bio);
    await prefs.setInt(_avatarKey, _avatarIndex);
    await prefs.setInt(_frameKey, _frameIndex);
    notifyListeners();
  }

  Future<void> resetLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_bioKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_frameKey);
    _name = 'Путник';
    _bio = 'Мой путь начинается сегодня.';
    _avatarIndex = 0;
    _frameIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
