import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int tab = 0;
  final searchController = TextEditingController();

  final directory = <Map<String, String>>[
    {'name': 'Artem', 'nick': 'artem_01', 'id': '204817', 'league': 'Алмазная лига'},
    {'name': 'Maksim', 'nick': 'maksim.fit', 'id': '105729', 'league': 'Платиновая лига'},
    {'name': 'Daniil', 'nick': 'dan_vision', 'id': '882164', 'league': 'Золотая лига'},
    {'name': 'Timur', 'nick': 'timur.focus', 'id': '731095', 'league': 'Алмазная лига'},
    {'name': 'Eldar', 'nick': 'eldar_move', 'id': '410286', 'league': 'Золотая лига'},
    {'name': 'Alex', 'nick': 'alex.mind', 'id': '593108', 'league': 'Серебряная лига'},
  ];

  final friends = <Map<String, String>>[];
  final conversations = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab.clamp(0, 1).toInt();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Личные сообщения', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
    ),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: VirilColors.black.withValues(alpha: .75), borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
            child: Row(children: [
              _tabButton('Чат', Icons.chat_bubble_rounded, 0),
              _tabButton('Друзья', Icons.people_alt_rounded, 1),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(child: IndexedStack(index: tab, children: [_chats(), _friends()])),
        ]),
      ),
    ),
  );

  Widget _tabButton(String label, IconData icon, int index) => Expanded(child: GestureDetector(
    onTap: () => setState(() => tab = index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: tab == index ? VirilColors.gold.withValues(alpha: .14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tab == index ? VirilColors.gold.withValues(alpha: .38) : Colors.transparent),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 17, color: tab == index ? VirilColors.gold : VirilColors.muted),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: tab == index ? VirilColors.gold : VirilColors.muted)),
      ]),
    ),
  ));

  Widget _chats() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _sectionHeading('ПОСЛЕДНИЕ ДИАЛОГИ', '${conversations.length}'),
    const SizedBox(height: 10),
    Expanded(child: ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (_, i) {
        final person = conversations[i];
        return _surface(child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          onTap: () => _openChat(person),
          leading: _avatar(person['name']!),
          title: Text(person['name']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(person['last']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirilColors.muted, fontSize: 10))),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(person['time']!, style: const TextStyle(color: VirilColors.subdued, fontSize: 9)),
            const SizedBox(height: 6),
            const Icon(Icons.chevron_right_rounded, color: VirilColors.gold, size: 18),
          ]),
        ));
      },
    )),
    _demoNote(),
  ]);

  Widget _friends() {
    final query = searchController.text.trim().toLowerCase().replaceAll('@', '');
    final results = directory.where((person) =>
      person['nick']!.toLowerCase().contains(query) ||
      person['id']!.contains(query) ||
      person['name']!.toLowerCase().contains(query)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _sectionHeading('МОИ ДРУЗЬЯ', '${friends.length}'),
      const SizedBox(height: 10),
      TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Поиск по ID или никнейму',
          prefixIcon: const Icon(Icons.search_rounded, color: VirilColors.gold),
          suffixIcon: searchController.text.isEmpty ? null : IconButton(onPressed: () { searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
          filled: true,
          fillColor: VirilColors.stone,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: VirilColors.line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: VirilColors.line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: VirilColors.gold, width: 1.3)),
        ),
      ),
      const SizedBox(height: 8),
      if (query.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: _sectionHeading('РЕЗУЛЬТАТЫ ПОИСКА', '${results.length}')),
      Expanded(child: ListView.separated(
        itemCount: query.isEmpty ? friends.length : results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final person = query.isEmpty ? friends[i] : results[i];
          final isFriend = friends.any((f) => f['id'] == person['id']);
          return _surface(child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: _avatar(person['name']!),
            title: Text(person['name']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            subtitle: Padding(padding: const EdgeInsets.only(top: 3), child: Text('@${person['nick']}  ·  ID ${person['id']}\n${person['league']}', style: const TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.5))),
            isThreeLine: true,
            trailing: query.isNotEmpty && !isFriend
              ? IconButton(onPressed: () => _addFriend(person), icon: const Icon(Icons.person_add_alt_1_rounded, color: VirilColors.gold))
              : IconButton(onPressed: () => _openChat(person), icon: const Icon(Icons.chat_bubble_outline_rounded, color: VirilColors.gold)),
          ));
        },
      )),
      _demoNote(),
    ]);
  }

  Widget _sectionHeading(String title, String count) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.25, fontWeight: FontWeight.w900))),
    Text(count, style: const TextStyle(color: VirilColors.subdued, fontSize: 10)),
  ]);

  Widget _surface({required Widget child}) => Container(
    decoration: BoxDecoration(color: VirilColors.stone.withValues(alpha: .94), borderRadius: BorderRadius.circular(17), border: Border.all(color: VirilColors.line)),
    child: child,
  );

  Widget _avatar(String name) => CircleAvatar(
    radius: 22,
    backgroundColor: VirilColors.navyLight,
    child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, fontSize: 16)),
  );

  Widget _demoNote() => const Padding(
    padding: EdgeInsets.only(top: 9),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: VirilColors.subdued, size: 13),
      SizedBox(width: 6),
      Expanded(child: Text('Демо-режим · профили и сообщения пока локальные', style: TextStyle(color: VirilColors.subdued, fontSize: 9))),
    ]),
  );

  void _addFriend(Map<String, String> person) {
    if (friends.any((friend) => friend['id'] == person['id'])) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Этот пользователь уже у тебя в друзьях.')));
      return;
    }
    setState(() => friends.add(person));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${person['name']} добавлен в друзья.')));
  }

  void _openChat(Map<String, String> person) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _DemoChatScreen(person: person)));
  }
}

class _DemoChatScreen extends StatefulWidget {
  const _DemoChatScreen({required this.person});
  final Map<String, String> person;

  @override
  State<_DemoChatScreen> createState() => _DemoChatScreenState();
}

class _DemoChatScreenState extends State<_DemoChatScreen> {
  final controller = TextEditingController();
  final messages = <Map<String, dynamic>>[
    {'text': 'Привет! Добро пожаловать в демо-чат Viril.', 'mine': false, 'time': '12:40'},
    {'text': 'Здесь можно проверить, как будет выглядеть переписка.', 'mine': false, 'time': '12:41'},
  ];

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      title: Row(children: [
        CircleAvatar(radius: 17, backgroundColor: VirilColors.navyLight, child: Text(widget.person['name']![0], style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.person['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          Text('@${widget.person['nick']} · ID ${widget.person['id']}', style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
        ])),
      ]),
    ),
    body: Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final message = messages[i];
          final mine = message['mine'] as bool;
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 290),
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
              decoration: BoxDecoration(
                color: mine ? VirilColors.navy : VirilColors.stone,
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(15), topRight: const Radius.circular(15), bottomLeft: Radius.circular(mine ? 15 : 4), bottomRight: Radius.circular(mine ? 4 : 15)),
                border: Border.all(color: mine ? VirilColors.gold.withValues(alpha: .25) : VirilColors.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(message['text'] as String, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white)),
                const SizedBox(height: 4),
                Text(message['time'] as String, style: const TextStyle(fontSize: 8, color: VirilColors.subdued)),
              ]),
            ),
          );
        },
      )),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(children: [
          Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Написать сообщение…'))),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _send,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.black),
          ),
        ]),
      )),
    ]),
  );

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() => messages.add({'text': value, 'mine': true, 'time': TimeOfDay.now().format(context)}));
    controller.clear();
  }
}
