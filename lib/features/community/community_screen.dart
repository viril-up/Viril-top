import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int tab = 0;
  final friends = <Map<String, String>>[
    {'name':'Artem','nick':'artem_01','id':'VR-20481','league':'Алмазная лига'},
    {'name':'Maksim','nick':'maksim.fit','id':'VR-10572','league':'Платиновая лига'},
    {'name':'Daniil','nick':'dan_vision','id':'VR-88216','league':'Золотая лига'},
  ];
  final suggestions = <Map<String, String>>[
    {'name':'Timur','nick':'timur.focus','id':'VR-73109','league':'Алмазная лига'},
    {'name':'Eldar','nick':'eldar_move','id':'VR-41028','league':'Золотая лига'},
  ];
  final clans = <Map<String, String>>[
    {'name':'IRON MIND','nick':'ironmind','id':'CM-001842','desc':'Дисциплина, сила характера и ежедневный прогресс.','access':'Открытое','league':'Алмазная и выше','members':'18'},
    {'name':'READING CLUB','nick':'readingclub','id':'CM-002193','desc':'Обмениваемся идеями и обсуждаем прочитанное.','access':'По приглашению','league':'Любая лига','members':'42'},
    {'name':'MORNING RUN','nick':'morningrun','id':'CM-003014','desc':'Утренние пробежки и движение к своим целям.','access':'Закрытое','league':'Золотая и выше','members':'27'},
  ];
  final dialogs = <Map<String, String>>[
    {'name':'Artem','last':'Сегодня закрыл все цели. Отличный день!','time':'12:48','id':'VR-20481'},
    {'name':'Maksim','last':'Завтра пробежка в 7:00?','time':'Вчера','id':'VR-10572'},
    {'name':'Daniil','last':'Спасибо за совет по тренировкам.','time':'Пн','id':'VR-88216'},
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Сообщество', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          SizedBox(height: 3),
          Text('ТВОЁ ОКРУЖЕНИЕ. ТВОЙ ПРОГРЕСС.', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
        ])),
        _iconBox(Icons.forum_rounded),
      ]),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: VirilColors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
        child: Row(children: [
          _tabButton('Чат', Icons.chat_bubble_outline_rounded, 0),
          _tabButton('Друзья', Icons.people_alt_outlined, 1),
          _tabButton('Сообщества', Icons.shield_outlined, 2),
        ])),
      const SizedBox(height: 16),
      Expanded(child: IndexedStack(index: tab, children: [_chats(), _friends(), _communities()])),
    ]),
  );

  Widget _tabButton(String label, IconData icon, int index) => Expanded(child: GestureDetector(
    onTap: () => setState(() => tab = index),
    child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(color: tab == index ? VirilColors.gold.withValues(alpha: .14) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: tab == index ? VirilColors.gold.withValues(alpha: .35) : Colors.transparent)),
      child: Column(children: [
        Icon(icon, size: 18, color: tab == index ? VirilColors.gold : VirilColors.muted),
        const SizedBox(height: 4),
        Text(label, maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tab == index ? VirilColors.gold : VirilColors.muted)),
      ]),
    ),
  ));

  Widget _chats() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _heading('ЛИЧНЫЕ СООБЩЕНИЯ', dialogs.length.toString() + ' диалога'),
    const SizedBox(height: 10),
    _globalChat(),
    const SizedBox(height: 9),
    Expanded(child: ListView.separated(itemCount: dialogs.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
      final d = dialogs[i];
      return _panel(child: ListTile(
        onTap: () => _openChat(d['name']!, d['id']!),
        leading: _avatar(d['name']!),
        title: Text(d['name']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text(d['last']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
        trailing: Text(d['time']!, style: const TextStyle(color: VirilColors.subdued, fontSize: 9)),
      ));
    })),
    _note(),
  ]);

  Widget _globalChat() => _panel(color: VirilColors.navy, child: ListTile(
    onTap: () => _openChat('VIRIL GLOBAL', 'Общий чат участников'),
    leading: const CircleAvatar(backgroundColor: VirilColors.cosmicBlue, child: Icon(Icons.public_rounded, color: VirilColors.chartBlueLight)),
    title: const Text('VIRIL GLOBAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
    subtitle: const Text('Общий чат участников Viril', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: VirilColors.gold),
  ));

  Widget _friends() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [
      Expanded(child: _heading('МОИ ДРУЗЬЯ', friends.length.toString())),
      FilledButton.icon(onPressed: _findFriend, icon: const Icon(Icons.person_search_rounded, size: 17), label: const Text('Найти')),
    ]),
    const SizedBox(height: 10),
    Expanded(child: ListView.separated(itemCount: friends.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
      final p = friends[i];
      return _panel(child: ListTile(
        leading: _avatar(p['name']!),
        title: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text('@' + p['nick']! + ' · ' + p['id']! + '\n' + p['league']!, style: const TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.5)),
        isThreeLine: true,
        trailing: IconButton(onPressed: () => _openChat(p['name']!, p['id']!), icon: const Icon(Icons.chat_bubble_outline_rounded, color: VirilColors.gold)),
      ));
    })),
    _note(),
  ]);

  Widget _communities() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [
      const Expanded(child: Text('КЛАНЫ ПО ИНТЕРЕСАМ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900))),
      FilledButton.icon(onPressed: _createCommunity, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Создать')),
    ]),
    const SizedBox(height: 10),
    Expanded(child: ListView.separated(itemCount: clans.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
      final c = clans[i];
      return _panel(child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _openClan(c),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(height: 76, padding: const EdgeInsets.all(13), decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            gradient: LinearGradient(colors: [VirilColors.navyLight, VirilColors.violet, VirilColors.black])),
            child: Row(children: [
              Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: VirilColors.black.withValues(alpha: .6), borderRadius: BorderRadius.circular(12), border: Border.all(color: VirilColors.gold)),
                child: Text(c['name']!.substring(0, 1), style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, fontSize: 19))),
              const Spacer(),
              _pill(c['access']!),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(c['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
              Text(c['members']! + ' участников', style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
            ]),
            const SizedBox(height: 3),
            Text('@' + c['nick']! + ' · ' + c['id']!, style: const TextStyle(color: VirilColors.subdued, fontSize: 9)),
            const SizedBox(height: 7),
            Text(c['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.military_tech_rounded, size: 14, color: VirilColors.gold),
              const SizedBox(width: 5),
              Expanded(child: Text(c['league']!, style: const TextStyle(color: VirilColors.gold, fontSize: 9))),
              const Text('ОТКРЫТЬ  ›', style: TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, fontSize: 9)),
            ]),
          ])),
        ]),
      ));
    })),
    _note(),
  ]);

  Widget _heading(String title, String trailing) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w900))),
    Text(trailing, style: const TextStyle(color: VirilColors.subdued, fontSize: 10)),
  ]);
  Widget _panel({required Widget child, Color? color}) => Container(
    decoration: BoxDecoration(color: color ?? VirilColors.stone, borderRadius: BorderRadius.circular(17), border: Border.all(color: VirilColors.line)),
    child: child);
  Widget _avatar(String name) => CircleAvatar(radius: 22, backgroundColor: VirilColors.navyLight, child: Text(name.substring(0, 1), style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)));
  Widget _pill(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: VirilColors.black.withValues(alpha: .65), borderRadius: BorderRadius.circular(20), border: Border.all(color: VirilColors.gold.withValues(alpha: .4))), child: Text(label.toUpperCase(), style: const TextStyle(color: VirilColors.gold, fontSize: 8, fontWeight: FontWeight.w900)));
  Widget _iconBox(IconData icon) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(14), border: Border.all(color: VirilColors.line)), child: Icon(icon, color: VirilColors.gold));
  Widget _note() => const Padding(padding: EdgeInsets.only(top: 8), child: Row(children: [
    Icon(Icons.info_outline_rounded, color: VirilColors.subdued, size: 13), SizedBox(width: 6),
    Expanded(child: Text('Демонстрационный режим · данные пока не синхронизируются', style: TextStyle(color: VirilColors.subdued, fontSize: 9))),
  ]));

  Future<void> _findFriend() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: VirilColors.stone,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) {
        final q = controller.text.trim().toLowerCase();
        final matches = suggestions.where((p) => p['nick']!.toLowerCase().contains(q) || p['id']!.toLowerCase().contains(q) || p['name']!.toLowerCase().contains(q)).toList();
        return Padding(padding: EdgeInsets.fromLTRB(18, 20, 18, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Найти пользователя', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('По уникальному ID или никнейму', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 12),
            TextField(controller: controller, onChanged: (_) => refresh(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'VR-73109 или timur.focus')),
            const SizedBox(height: 10),
            if (q.isEmpty) const Text('Введи имя, ID или никнейм пользователя.', style: TextStyle(color: VirilColors.muted))
            else if (matches.isEmpty) const Text('Совпадений в демо-списке нет.', style: TextStyle(color: VirilColors.muted))
            else ...matches.map((p) => ListTile(
              leading: _avatar(p['name']!),
              title: Text(p['name']!),
              subtitle: Text('@' + p['nick']! + ' · ' + p['id']!),
              trailing: TextButton(onPressed: () {
                setState(() => friends.add(p));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Друг добавлен в демо-список.')));
              }, child: const Text('Добавить')),
            )),
          ]));
      }));
    controller.dispose();
  }

  Future<void> _createCommunity() async {
    final name = TextEditingController();
    final nick = TextEditingController();
    final desc = TextEditingController();
    String access = 'Открытое';
    String league = 'Любая лига';
    String banner = 'Ночной синий';
    bool invite = false;
    final result = await showModalBottomSheet<Map<String, String>>(context: context, isScrollControlled: true, backgroundColor: VirilColors.stone,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => SafeArea(
        child: Padding(padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
          child: SizedBox(height: MediaQuery.of(ctx).size.height * .82, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Создать сообщество', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Настрой свой клан по интересам', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 12),
            Expanded(child: ListView(children: [
              _formLabel('НАЗВАНИЕ'),
              TextField(controller: name, maxLength: 30, decoration: const InputDecoration(hintText: 'Например, IRON MIND')),
              _formLabel('УНИКАЛЬНЫЙ НИКНЕЙМ'),
              TextField(controller: nick, maxLength: 20, decoration: const InputDecoration(hintText: 'Например, ironmind')),
              _formLabel('ОПИСАНИЕ'),
              TextField(controller: desc, maxLength: 180, maxLines: 3, decoration: const InputDecoration(hintText: 'О чём твоё сообщество?')),
              _formLabel('ТИП ДОСТУПА'),
              DropdownButtonFormField<String>(value: access, items: ['Открытое','Закрытое','По приглашению'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => refresh(() => access = v ?? access)),
              _formLabel('МИНИМАЛЬНАЯ ЛИГА'),
              DropdownButtonFormField<String>(value: league, items: ['Любая лига','Бронзовая и выше','Серебряная и выше','Золотая и выше','Платиновая и выше','Алмазная и выше'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => refresh(() => league = v ?? league)),
              _formLabel('ДИЗАЙН ШАПКИ И ЗНАМЕНИ'),
              DropdownButtonFormField<String>(value: banner, items: ['Ночной синий','Королевский фиолетовый','Лава и золото','Ледяной графит'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => refresh(() => banner = v ?? banner)),
              SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, value: invite, activeColor: VirilColors.gold, onChanged: (v) => refresh(() => invite = v),
                title: const Text('Только по приглашению', style: TextStyle(fontSize: 12)), subtitle: const Text('Дополнительное ограничение входа', style: TextStyle(color: VirilColors.muted, fontSize: 10))),
              const Text('ID присваивается автоматически. Уникальность никнейма будет проверяться сервером.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
            ])),
            const SizedBox(height: 8),
            FilledButton(onPressed: () {
              final n = name.text.trim();
              final h = nick.text.trim().replaceAll('@', '');
              if (n.isEmpty || h.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполни название и никнейм.')));
                return;
              }
              Navigator.pop(ctx, {'name':n.toUpperCase(),'nick':h,'id':'CM-' + DateTime.now().millisecondsSinceEpoch.toString().substring(7),'desc':desc.text.trim(),'access':invite ? 'По приглашению' : access,'league':league,'members':'1','banner':banner});
            }, child: const Text('Создать сообщество')),
          ])),
        ),
      )));
    name.dispose(); nick.dispose(); desc.dispose();
    if (result != null) setState(() => clans.insert(0, result));
  }

  Widget _formLabel(String s) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 5), child: Text(s, style: const TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w900)));

  void _openClan(Map<String, String> c) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ClanScreen(clan: c)));
  }
  void _openChat(String name, String subtitle) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _TextChatScreen(name: name, subtitle: subtitle)));
  }
}

class _ClanScreen extends StatelessWidget {
  const _ClanScreen({required this.clan});
  final Map<String, String> clan;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Сообщество')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(height: 145, alignment: Alignment.bottomLeft, padding: const EdgeInsets.all(17),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), gradient: LinearGradient(colors: [VirilColors.navyLight, VirilColors.violet, VirilColors.black])),
        child: Text(clan['name']!, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
      const SizedBox(height: 14),
      Text('@' + clan['nick']!, style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text('ID: ' + clan['id']!, style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
      const SizedBox(height: 14),
      Text(clan['desc']!.isEmpty ? 'Сообщество Viril.' : clan['desc']!, style: const TextStyle(height: 1.5)),
      const SizedBox(height: 14),
      _row('Доступ', clan['access']!),
      _row('Минимальная лига', clan['league']!),
      _row('Участники', clan['members']!),
      _row('Оформление', clan['banner'] ?? 'Ночной синий'),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TextChatScreen(name: clan['name']!, subtitle: 'Общий чат сообщества'))), icon: const Icon(Icons.forum_rounded), label: const Text('Открыть общий чат')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Действие доступно в демо-превью.'))), icon: const Icon(Icons.login_rounded), label: const Text('Вступить в сообщество')),
      const SizedBox(height: 10),
      const Text('В полноценной версии владелец сможет менять шапку и знамя сообщества.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
    ]),
  );
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: VirilColors.muted, fontSize: 12))), Text(b, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]));
}

class _TextChatScreen extends StatefulWidget {
  const _TextChatScreen({required this.name, required this.subtitle});
  final String name, subtitle;
  @override
  State<_TextChatScreen> createState() => _TextChatScreenState();
}
class _TextChatScreenState extends State<_TextChatScreen> {
  final controller = TextEditingController();
  final messages = <String>['Добро пожаловать в чат Viril. Здесь можно общаться текстовыми сообщениями.'];
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      Text(widget.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
    ])),
    body: Column(children: [
      Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) => Align(
        alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), constraints: const BoxConstraints(maxWidth: 290),
          decoration: BoxDecoration(color: i.isEven ? VirilColors.stone : VirilColors.navy, borderRadius: BorderRadius.circular(14), border: Border.all(color: VirilColors.line)),
          child: Text(messages[i], style: const TextStyle(fontSize: 12, height: 1.4))),
      ))),
      SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(children: [
        Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Написать сообщение…'))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: () {
          final value = controller.text.trim();
          if (value.isEmpty) return;
          setState(() => messages.add(value));
          controller.clear();
        }, icon: const Icon(Icons.send_rounded), style: IconButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.black)),
      ]))),
    ]),
  );
}
