import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _nameKey = 'viril.profile.name.v1';
  static const _bioKey = 'viril.profile.bio.v1';
  static const _avatarKey = 'viril.profile.avatar.v1';

  String _name = 'Путник';
  String _bio = 'Мой путь начинается сегодня.';
  int _avatarIndex = 0;
  bool _ready = false;

  String get name => _name;
  String get bio => _bio;
  int get avatarIndex => _avatarIndex;
  bool get isReady => _ready;

  static const avatarIcons = <int>[
    0xe491, // person
    0xe491,
    0xe3a6, // psychology-like icon fallback handled in UI
    0xe8f9,
    0xe87c,
    0xe8dc,
  ];

  Future<void> initialize() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? _name;
    _bio = prefs.getString(_bioKey) ?? _bio;
    _avatarIndex = prefs.getInt(_avatarKey) ?? 0;
    _ready = true;
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String bio, required int avatarIndex}) async {
    final cleanName = name.trim();
    _name = cleanName.isEmpty ? 'Путник' : cleanName;
    _bio = bio.trim();
    _avatarIndex = avatarIndex.clamp(0, 5).toInt();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_bioKey, _bio);
    await prefs.setInt(_avatarKey, _avatarIndex);
    notifyListeners();
  }
}
