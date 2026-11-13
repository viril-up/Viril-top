import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceStore extends ChangeNotifier {
  ResourceStore._();
  static final ResourceStore instance = ResourceStore._();
  static const _favoritesKey = 'viril.resource_favorites.v1';
  static const _notesKey = 'viril.resource_notes.v1';

  Set<String> _favorites = {};
  Map<String, String> _notes = {};
  bool _ready = false;
  bool get isReady => _ready;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Map<String, String> get notes => Map.unmodifiable(_notes);
  bool isFavorite(String id) => _favorites.contains(id);
  String noteFor(String id) => _notes[id] ?? '';

  Future<void> initialize() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList(_favoritesKey) ?? []).toSet();
    _notes = {};
    for (final entry in prefs.getKeys().where((key) => key.startsWith(_notesKey))) {
      final id = entry.substring(_notesKey.length);
      final value = prefs.getString(entry);
      if (value != null) _notes[id] = value;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
    notifyListeners();
  }

  Future<void> saveNote(String id, String note) async {
    final clean = note.trim();
    final prefs = await SharedPreferences.getInstance();
    if (clean.isEmpty) {
      _notes.remove(id);
      await prefs.remove('$_notesKey$id');
    } else {
      _notes[id] = clean;
      await prefs.setString('$_notesKey$id', clean);
    }
    notifyListeners();
  }
}
