import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/viril_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _search = TextEditingController();
  int _tab = 0;
  int _reload = 0;
  bool _searching = false;
  List<Map<String, dynamic>> _results = [];
  SupabaseClient get _db => SupabaseService.client;
  String? get _uid => _db.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2).toInt();
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _refresh() => setState(() => _reload++);

  Future<void> _findUsers(String value) async {
    final query = value.trim().replaceFirst(RegExp(r'^@'), '');
    if (query.isEmpty || _uid == null) {
      setState(() { _results = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    try {
      final rows = await _db.rpc('viril_search_users', params: {'p_query': query});
      if (!mounted) return;
      setState(() {
        _results = (rows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      _message('Не удалось выполнить поиск: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _friends() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _db.from('friendships').select('user_low,user_high')
      .or('user_low.eq.$uid,user_high.eq.$uid');
    final ids = (rows as List).map((r) =>
      r['user_low'] == uid ? r['user_high'].toString() : r['user_low'].toString()).toList();
    if (ids.isEmpty) return [];
    final profiles = await _db.from('profiles')
      .select('user_id,public_id,nickname,full_name,avatar_url')
      .inFilter('user_id', ids);
    return (profiles as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> _incomingRequests() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _db.from('friend_requests')
      .select('id,requester_id,created_at')
      .eq('recipient_id', uid).eq('status', 'pending')
      .order('created_at', ascending: false);
    final requests = (rows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (requests.isEmpty) return [];
    final ids = requests.map((e) => e['requester_id'].toString()).toList();
    final profiles = await _db.from('profiles')
      .select('user_id,public_id,nickname,full_name,avatar_url').inFilter('user_id', ids);
    final byId = {for (final p in profiles as List) p['user_id'].toString(): Map<String,dynamic>.from(p as Map)};
    return requests.map((r) => {...r, 'profile': byId[r['requester_id'].toString()] ?? {}}).toList();
  }

  Future<List<Map<String, dynamic>>> _conversations() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _db.rpc('viril_list_dm_peers');
    final peers = (rows as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
    final output = <Map<String, dynamic>>[];
    for (final item in peers) {
      final id = item['conversation_id'].toString();
      final peer = item['peer_user_id'].toString();
      final profileRows = await _db.from('profiles')
        .select('user_id,public_id,nickname,full_name,avatar_url').eq('user_id', peer).limit(1);
      if ((profileRows as List).isEmpty) continue;
      final lastRows = await _db.from('dm_messages')
        .select('body,created_at').eq('conversation_id', id)
        .order('created_at', ascending: false).limit(1);
      final last = (lastRows as List).isEmpty ? null : lastRows.first;
      output.add({
        'conversation_id': id,
        'profile': Map<String,dynamic>.from(profileRows.first as Map),
        'last_message': last == null ? 'Начните общение' : last['body'].toString(),
        'created_at': last == null ? '' : last['created_at'].toString(),
      });
    }
    output.sort((a,b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
    return output;
  }

  Future<void> _sendRequest(Map<String, dynamic> person) async {
    try {
      await _db.rpc('viril_send_friend_request', params: {'p_recipient_id': person['user_id']});
      _message('Заявка отправлена. После взаимного подтверждения откроется чат.');
      await _findUsers(_search.text);
      _refresh();
    } catch (e) { _message(_friendlyError(e)); }
  }

  Future<void> _respond(Map<String, dynamic> request, bool accept) async {
    try {
      await _db.rpc('viril_respond_friend_request', params: {
        'p_request_id': request['id'], 'p_accept': accept,
      });
      _message(accept ? 'Теперь вы друзья. Можно начинать переписку.' : 'Заявка отклонена.');
      _refresh();
    } catch (e) { _message(_friendlyError(e)); }
  }

  Future<void> _openChat(Map<String, dynamic> person) async {
    try {
      final id = await _db.rpc('viril_create_dm', params: {'p_friend_id': person['user_id']});
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => _DirectChatScreen(conversationId: id.toString(), person: person),
      ));
      _refresh();
    } catch (e) { _message(_friendlyError(e)); }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('Already friends')) return 'Этот пользователь уже у тебя в друзьях.';
    if (text.contains('already pending')) return 'Заявка уже отправлена или обработана.';
    if (text.contains('Mutual friendship required')) return 'Для переписки сначала нужно стать друзьями.';
    if (text.contains('Authentication required')) return 'Войди в аккаунт Viril, чтобы пользоваться друзьями и сообщениями.';
    return 'Не удалось выполнить действие. Проверь подключение и попробуй ещё раз.';
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(appBar: AppBar(title: const Text('Личные сообщения')),
        body: const Center(child: Padding(padding: EdgeInsets.all(24),
          child: Text('Войди в аккаунт Viril, чтобы добавлять друзей и переписываться.', textAlign: TextAlign.center))));
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Личные сообщения', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
      body: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: VirilColors.black.withValues(alpha: .75),
              borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
            child: Row(children: [
              _tabButton('Чаты', Icons.chat_bubble_rounded, 0),
              _tabButton('Друзья', Icons.people_alt_rounded, 1),
              _tabButton('Заявки', Icons.person_add_alt_1_rounded, 2),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(child: IndexedStack(index: _tab, children: [_chats(), _friendsTab(), _requestsTab()])),
        ]),
      )),
    );
  }

  Widget _tabButton(String title, IconData icon, int index) => Expanded(child: InkWell(
    onTap: () => setState(() => _tab = index),
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: _tab == index ? VirilColors.gold.withValues(alpha: .14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _tab == index ? VirilColors.gold.withValues(alpha: .38) : Colors.transparent)),
      child: Column(children: [
        Icon(icon, size: 17, color: _tab == index ? VirilColors.gold : VirilColors.muted),
        const SizedBox(height: 3),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
          color: _tab == index ? VirilColors.gold : VirilColors.muted)),
      ]),
    ),
  ));

  Widget _chats() => FutureBuilder<List<Map<String,dynamic>>>(
    key: ValueKey('chats$_reload'), future: _conversations(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return _errorState(snapshot.error);
      final rows = snapshot.data ?? [];
      if (rows.isEmpty) return _empty('Пока нет диалогов', 'Добавь пользователя в друзья — после подтверждения можно будет начать переписку.');
      return ListView.separated(itemCount: rows.length, separatorBuilder: (_,__) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final row = rows[i]; final p = row['profile'] as Map<String,dynamic>;
          return _personTile(p, subtitle: row['last_message'].toString(),
            trailing: const Icon(Icons.chevron_right_rounded, color: VirilColors.gold),
            onTap: () => _openChat(p));
        });
    });

  Widget _friendsTab() => Column(children: [
    TextField(controller: _search, onChanged: _findUsers,
      decoration: InputDecoration(hintText: 'Найти по ID или никнейму',
        prefixIcon: const Icon(Icons.search_rounded, color: VirilColors.gold),
        suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () {
          _search.clear(); setState(() => _results = []);
        }, icon: const Icon(Icons.close_rounded)))),
    const SizedBox(height: 10),
    if (_search.text.trim().isNotEmpty) ...[
      Expanded(child: _searching ? const Center(child: CircularProgressIndicator())
        : _results.isEmpty ? _empty('Ничего не найдено', 'Проверь ID или никнейм пользователя.')
        : ListView.separated(itemCount: _results.length, separatorBuilder: (_,__) => const SizedBox(height: 8),
          itemBuilder: (_,i) {
            final p = _results[i];
            return _personTile(p, subtitle: 'ID ${p['public_id'] ?? '—'}',
              trailing: IconButton(onPressed: () => _sendRequest(p),
                icon: const Icon(Icons.person_add_alt_1_rounded, color: VirilColors.gold)),
              onTap: () => _sendRequest(p));
          })),
    ] else ...[
      Expanded(child: FutureBuilder<List<Map<String,dynamic>>>(
        key: ValueKey('friends$_reload'), future: _friends(),
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _errorState(snapshot.error);
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return _empty('Пока нет друзей', 'Найди пользователя по уникальному ID или никнейму и отправь заявку.');
          return ListView.separated(itemCount: rows.length, separatorBuilder: (_,__) => const SizedBox(height: 8),
            itemBuilder: (_,i) => _personTile(rows[i], subtitle: 'ID ${rows[i]['public_id'] ?? '—'}',
              trailing: const Icon(Icons.chat_bubble_outline_rounded, color: VirilColors.gold),
              onTap: () => _openChat(rows[i])));
        })),
    ],
  ]);

  Widget _requestsTab() => FutureBuilder<List<Map<String,dynamic>>>(
    key: ValueKey('requests$_reload'), future: _incomingRequests(),
    builder: (context,snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return _errorState(snapshot.error);
      final rows = snapshot.data ?? [];
      if (rows.isEmpty) return _empty('Нет новых заявок', 'Когда кто-нибудь отправит тебе заявку в друзья, она появится здесь.');
      return ListView.separated(itemCount: rows.length, separatorBuilder: (_,__) => const SizedBox(height: 8),
        itemBuilder: (_,i) {
          final r = rows[i]; final p = r['profile'] as Map<String,dynamic>;
          return _surface(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
            _personTile(p, subtitle: 'Хочет добавить тебя в друзья', trailing: const SizedBox.shrink(), onTap: () {}),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => _respond(r,false), child: const Text('Отклонить'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: () => _respond(r,true),
                style: FilledButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.black),
                child: const Text('Принять'))),
            ]),
          ])));
        });
    });

  Widget _personTile(Map<String,dynamic> p, {required String subtitle, required Widget trailing, required VoidCallback onTap}) {
    final name = (p['full_name'] ?? '').toString().trim().isNotEmpty
      ? p['full_name'].toString() : (p['nickname'] ?? 'Пользователь').toString();
    return _surface(child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      leading: CircleAvatar(radius: 21, backgroundColor: VirilColors.navyLight,
        child: Text(name.isEmpty ? 'V' : name[0].toUpperCase(), style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      subtitle: Text('@${p['nickname'] ?? '—'} · $subtitle', style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      trailing: trailing));
  }

  Widget _surface({required Widget child}) => Container(
    decoration: BoxDecoration(color: VirilColors.stone.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)), child: child);
  Widget _empty(String title, String detail) => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.forum_outlined, size: 34, color: VirilColors.gold),
      const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 6), Text(detail, textAlign: TextAlign.center,
        style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
    ])));
  Widget _errorState(Object? error) => _empty('Не удалось загрузить данные', 'Проверь интернет и попробуй обновить экран.');
}

class _DirectChatScreen extends StatefulWidget {
  const _DirectChatScreen({required this.conversationId, required this.person});
  final String conversationId;
  final Map<String,dynamic> person;
  @override
  State<_DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<_DirectChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  SupabaseClient get _db => SupabaseService.client;

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final name = (widget.person['full_name'] ?? widget.person['nickname'] ?? 'Пользователь').toString();
    final stream = _db.from('dm_messages').stream(primaryKey: ['id'])
      .eq('conversation_id', widget.conversationId).order('created_at');
    return Scaffold(backgroundColor: Colors.transparent,
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        Text('@${widget.person['nickname'] ?? ''}', style: const TextStyle(fontSize: 9, color: VirilColors.muted)),
      ])),
      body: Column(children: [
        Expanded(child: StreamBuilder<List<Map<String,dynamic>>>(stream: stream,
          builder: (context,snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Не удалось загрузить сообщения.'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final messages = snapshot.data!;
            if (messages.isEmpty) return const Center(child: Text('Начни переписку', style: TextStyle(color: VirilColors.muted)));
            return ListView.builder(reverse: false, padding: const EdgeInsets.all(14), itemCount: messages.length,
              itemBuilder: (_,i) {
                final m = messages[i]; final mine = m['sender_id'] == _db.auth.currentUser?.id;
                return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(constraints: const BoxConstraints(maxWidth: 290),
                    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: mine ? VirilColors.navy : VirilColors.stone,
                      borderRadius: BorderRadius.circular(14), border: Border.all(color: mine ? VirilColors.gold.withValues(alpha:.25) : VirilColors.line)),
                    child: Text(m['body'].toString(), style: const TextStyle(fontSize: 12, height: 1.4))));
              });
          })),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12,6,12,12),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 4,
              decoration: const InputDecoration(hintText: 'Написать сообщение…'))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _sending ? null : _send, icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.black)),
          ]))),
      ]));
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    final user = _db.auth.currentUser;
    if (body.isEmpty || user == null || _sending) return;
    setState(() => _sending = true);
    try {
      await _db.from('dm_messages').insert({
        'conversation_id': widget.conversationId,
        'sender_id': user.id,
        'body': body,
      });
      _controller.clear();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение не отправлено. Проверь подключение.')));
    } finally { if (mounted) setState(() => _sending = false); }
  }
}
