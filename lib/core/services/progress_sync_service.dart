import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/viril_store.dart';
import '../../features/goals/data/goal_store.dart';

class ProgressSyncService {
  ProgressSyncService._();
  static final ProgressSyncService instance = ProgressSyncService._();

  static const String _workerUrl =
      'https://viril-top.userqwertyuiopplus.workers.dev/api/progress';
  static const String _ownerKey = 'viril.progress.local_owner.v1';

  int _revision = 0;
  String? _syncedUserId;
  bool _busy = false;
  bool _applyingRemote = false;
  bool _listenersAttached = false;
  Timer? _uploadTimer;

  Future<void> syncForCurrentUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    final token = session?.accessToken;
    if (user == null || token == null || token.isEmpty || _busy) return;

    _busy = true;
    try {
      await VirilStore.instance.initialize();
      await GoalStore.instance.initialize();
      final prefs = await SharedPreferences.getInstance();
      final localOwner = prefs.getString(_ownerKey);

      final remote = await _getSnapshot(token);
      if (remote != null && remote['exists'] == true) {
        final snapshot = remote['snapshot'];
        if (snapshot is Map<String, dynamic>) {
          await _applySnapshot(snapshot);
          _revision = (remote['revision'] as num?)?.toInt() ?? 0;
          _syncedUserId = user.id;
          await prefs.setString(_ownerKey, user.id);
          _attachListeners();
          return;
        }
      }

      // Local data may be claimed by the first account on this installation.
      // It must never be copied from one signed-in account into another.
      if (localOwner != null && localOwner != user.id) {
        await _applySnapshot(_emptySnapshot());
      }
      final local = await _buildSnapshot();
      final saved = await _putSnapshot(token, local, null);
      if (saved != null) {
        _revision = (saved['revision'] as num?)?.toInt() ?? 1;
        _syncedUserId = user.id;
        await prefs.setString(_ownerKey, user.id);
        _attachListeners();
        return;
      }

      // A second device may have created the snapshot between GET and PUT.
      final latest = await _getSnapshot(token);
      if (latest != null && latest['exists'] == true &&
          latest['snapshot'] is Map<String, dynamic>) {
        await _applySnapshot(latest['snapshot'] as Map<String, dynamic>);
        _revision = (latest['revision'] as num?)?.toInt() ?? 0;
        _syncedUserId = user.id;
        await prefs.setString(_ownerKey, user.id);
        _attachListeners();
      }
    } catch (error, stackTrace) {
      debugPrint('Viril progress sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _busy = false;
    }
  }

  Map<String, dynamic> _emptySnapshot() => {
    'version': 1,
    'viril': {
      'xp': 0, 'vcoins': 0, 'tasks': <dynamic>[],
      'coinRewardedTasks': <String>[], 'purchasedItems': <String>[],
      'habitRewards': <String>[], 'activeDays': <String>[],
      'dailyXp': <String, int>{}, 'journalEntries': <dynamic>[],
      'gratitudeEntries': <dynamic>[],
    },
    'goals': <dynamic>[],
  };

  Future<Map<String, dynamic>> _buildSnapshot() async => {
    'version': 1,
    'viril': VirilStore.instance.exportSnapshot(),
    'goals': GoalStore.instance.exportSnapshot(),
  };

  Future<void> _applySnapshot(Map<String, dynamic> snapshot) async {
    _applyingRemote = true;
    try {
    final viril = snapshot['viril'];
    final goals = snapshot['goals'];
    await VirilStore.instance.importSnapshot(
      viril is Map<String, dynamic> ? viril : _emptySnapshot()['viril'] as Map<String, dynamic>,
    );
    await GoalStore.instance.importSnapshot(
      goals is List<dynamic> ? goals : <dynamic>[],
    );
    } finally {
      _applyingRemote = false;
    }
  }

  void _attachListeners() {
    if (_listenersAttached) return;
    VirilStore.instance.addListener(_scheduleUpload);
    GoalStore.instance.addListener(_scheduleUpload);
    _listenersAttached = true;
  }

  void onSignedOut() {
    _syncedUserId = null;
    _uploadTimer?.cancel();
  }

  void _scheduleUpload() {
    if (_applyingRemote || _syncedUserId == null) return;
    _uploadTimer?.cancel();
    _uploadTimer = Timer(const Duration(milliseconds: 900), _pushLocalChanges);
  }

  Future<void> _pushLocalChanges() async {
    if (_busy || _syncedUserId == null) return;
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    final token = session?.accessToken;
    if (user == null || user.id != _syncedUserId || token == null) return;
    _busy = true;
    try {
      final saved = await _putSnapshot(token, await _buildSnapshot(), _revision);
      if (saved != null) {
        _revision = (saved['revision'] as num?)?.toInt() ?? (_revision + 1);
        return;
      }
      final latest = await _getSnapshot(token);
      if (latest != null && latest['exists'] == true &&
          latest['snapshot'] is Map<String, dynamic>) {
        await _applySnapshot(latest['snapshot'] as Map<String, dynamic>);
        _revision = (latest['revision'] as num?)?.toInt() ?? _revision;
      }
    } catch (error, stackTrace) {
      debugPrint('Viril progress upload failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>?> _getSnapshot(String token) async {
    final response = await http.get(
      Uri.parse(_workerUrl),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Progress GET failed: HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<Map<String, dynamic>?> _putSnapshot(
    String token,
    Map<String, dynamic> snapshot,
    int? expectedRevision,
  ) async {
    final response = await http.put(
      Uri.parse(_workerUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'snapshot': snapshot,
        'expectedRevision': expectedRevision,
      }),
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 409) return null;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Progress PUT failed: HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }
}
