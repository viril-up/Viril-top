import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceStore extends ChangeNotifier {
  ResourceStore._();

  static final instance = ResourceStore._();

  static const _journalKey = 'viril.reading_journal.v1';
  static const _favoritesKey = 'viril.resource_favorites.v1';
  static const _completedToolsKey = 'viril.completed_development_tools.v1';
  static const _progressKey = 'viril.book_progress.v1';
  static const _bookmarksKey = 'viril.bookmarks.v1';
  static const _bookNotesKey = 'viril.book_notes.v1';

  Set<String> _favorites = {};
  Set<String> _completedTools = {};
  Map<String, int> _progress = {};
  Map<String, List<int>> _bookmarks = {};
  Map<String, String> _bookNotes = {};
  String _journal = '';
  bool _ready = false;

  bool get isReady => _ready;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Set<String> get completedTools => Set.unmodifiable(_completedTools);
  bool isFavorite(String id) => _favorites.contains(id);
  bool isToolCompleted(String id) => _completedTools.contains(id);
  int get completedToolsCount => _completedTools.length;

  int pageForBook(String id) => _progress[id] ?? 1;
  List<int> bookmarksForBook(String id) =>
      List.unmodifiable(_bookmarks[id] ?? const []);
  String noteForBookPage(String id, int page) => _bookNotes['$id:$page'] ?? '';
  String get journal => _journal;

  Future<void> initialize() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList(_favoritesKey) ?? []).toSet();
    _completedTools = (prefs.getStringList(_completedToolsKey) ?? []).toSet();

    _progress = {};
    for (final item in prefs.getStringList(_progressKey) ?? []) {
      final separator = item.lastIndexOf('|');
      if (separator > 0) {
        _progress[item.substring(0, separator)] =
            int.tryParse(item.substring(separator + 1)) ?? 1;
      }
    }

    _bookmarks = {};
    for (final item in prefs.getStringList(_bookmarksKey) ?? []) {
      final separator = item.lastIndexOf('|');
      if (separator > 0) {
        final id = item.substring(0, separator);
        final page = int.tryParse(item.substring(separator + 1));
        if (page != null) (_bookmarks[id] ??= []).add(page);
      }
    }

    _bookNotes = {};
    for (final key in prefs.getKeys().where((key) => key.startsWith(_bookNotesKey))) {
      final value = prefs.getString(key);
      if (value != null) {
        _bookNotes[key.substring(_bookNotesKey.length)] = value;
      }
    }

    _journal = prefs.getString(_journalKey) ?? '';
    _ready = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
    notifyListeners();
  }

  Future<void> setToolCompleted(String id, bool completed) async {
    completed ? _completedTools.add(id) : _completedTools.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedToolsKey, _completedTools.toList());
    notifyListeners();
  }

  Future<void> saveBookPage(String id, int page) async {
    _progress[id] = page < 1 ? 1 : page;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _progressKey,
      _progress.entries.map((item) => '${item.key}|${item.value}').toList(),
    );
    notifyListeners();
  }

  Future<void> toggleBookBookmark(String id, int page) async {
    final pages = _bookmarks[id] ??= [];
    pages.contains(page) ? pages.remove(page) : pages.add(page);
    pages.sort();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _bookmarksKey,
      _bookmarks.entries
          .expand((item) => item.value.map((page) => '${item.key}|$page'))
          .toList(),
    );
    notifyListeners();
  }

  Future<void> saveJournal(String value) async {
    _journal = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalKey, value);
    notifyListeners();
  }

  Future<void> saveBookPageNote(String id, int page, String note) async {
    final key = '$id:$page';
    final value = note.trim();
    final prefs = await SharedPreferences.getInstance();
    if (value.isEmpty) {
      _bookNotes.remove(key);
      await prefs.remove('$_bookNotesKey$key');
    } else {
      _bookNotes[key] = value;
      await prefs.setString('$_bookNotesKey$key', value);
    }
    notifyListeners();
  }
}
