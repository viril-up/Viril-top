import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import 'data/profile_store.dart';
import 'global_league_screen.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProfileStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([VirilStore.instance, ProfileStore.instance]),
    builder: (context, _) {
      final stats = VirilStore.instance;
      final profile = ProfileStore.instance;
      final league = _leagueFor(stats.xp);
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
        children: [
          _profileCover(profile, stats, league),
          const SizedBox(height: 14),
          _lifetimeStats(stats),
          const SizedBox(height: 22),
          _leagueCard(context, stats, league),
          const SizedBox(height: 22),
          _sectionLabel('ТВОЙ ПРОФИЛЬ'),
          const SizedBox(height: 10),
          _ActionTile(icon: Icons.person_add_alt_1_rounded, title: 'Зарегистрироваться',
            subtitle: 'Создать игровой аккаунт Viril через Google', onTap: () => _showRegistrationInfo(context)),
          _ActionTile(icon: Icons.quiz_outlined, title: 'Ответы на вопросы',
            subtitle: 'Всё, что нужно знать о приложении', onTap: () => _openFaq(context)),
          _ActionTile(icon: Icons.support_agent_rounded, title: 'Поддержка',
            subtitle: 'Написать команде Viril', onTap: () => _openSupport(context)),
          _ActionTile(icon: Icons.send_rounded, title: 'Менеджер TG',
            subtitle: '@Virilgo', onTap: () => _openTelegram(context)),
          const SizedBox(height: 16),
          Center(child: Text('VIRIL · ПУТЬ СОЗДАЁШЬ ТЫ', style: TextStyle(
            color: VirilColors.gold.withValues(alpha: .55), fontSize: 9, letterSpacing: 2.1, fontWeight: FontWeight.w800))),
        ],
      );
    },
  );

  Widget _profileCover(ProfileStore profile, VirilStore stats, _League league) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: VirilColors.gold.withValues(alpha: .38)),
        boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .08), blurRadius: 22, spreadRadius: 1)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/profile_cover/cover.jpg', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF38402F), Color(0xFF171B20), Color(0xFF4A3022)])))),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x5510141D), Color(0xCC090B12)], stops: [0.05, 1]))),
        Positioned(right: 13, top: 12, child: IconButton(
          tooltip: 'Настройки профиля',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSettingsScreen())),
          style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: .34),
            side: BorderSide(color: VirilColors.gold.withValues(alpha: .45))),
          icon: const Icon(Icons.settings_rounded, color: VirilColors.gold))),
        Positioned(left: 17, right: 16, bottom: 18, child: Row(children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(
            shape: BoxShape.circle, color: VirilColors.stone,
            border: Border.all(color: VirilColors.gold, width: 2),
            boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .25), blurRadius: 14)]),
            child: Icon(_avatarFor(profile.avatarIndex), size: 36, color: VirilColors.gold)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('УРОВЕНЬ ${stats.level}  ·  ${league.name.toUpperCase()}',
              style: const TextStyle(fontSize: 9, letterSpacing: 1.25, color: VirilColors.gold, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            InkWell(onTap: _editNickname, child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.edit_rounded, size: 12, color: VirilColors.ice),
              SizedBox(width: 5),
              Text('Изменить никнейм', style: TextStyle(fontSize: 10, color: VirilColors.ice)),
            ])),
          ])),
        ])),
      ]),
    );
  }

  Widget _lifetimeStats(VirilStore stats) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(color: VirilColors.stone.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: VirilColors.line)),
    child: Row(children: [
      _StatItem(icon: Icons.local_fire_department_rounded, value: '${stats.activeDaysCount}', label: 'АКТИВ'),
      _statDivider(),
      _StatItem(icon: Icons.bolt_rounded, value: '${stats.xp}', label: 'ОБЩИЙ XP'),
      _statDivider(),
      _StatItem(icon: Icons.task_alt_rounded, value: '${stats.completedCount}', label: 'ЗАДАЧ'),
      _statDivider(),
      _StatItem(icon: Icons.military_tech_rounded, value: '${stats.level}', label: 'УРОВЕНЬ'),
    ]),
  );

  Widget _statDivider() => Container(width: 1, height: 35, color: VirilColors.line);

  Widget _leagueCard(BuildContext context, VirilStore stats, _League league) => InkWell(
    borderRadius: BorderRadius.circular(23),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GlobalLeagueScreen())),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF302B20), Color(0xFF171923), Color(0xFF111722)]),
        border: Border.all(color: VirilColors.gold.withValues(alpha: .58)),
        boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .08), blurRadius: 20)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.shield_moon_rounded, color: VirilColors.gold, size: 22),
          const SizedBox(width: 9),
          const Expanded(child: Text('ГЛОБАЛЬНАЯ ЛИГА', style: TextStyle(color: VirilColors.gold, fontSize: 11,
            letterSpacing: 1.7, fontWeight: FontWeight.w900))),
          const Icon(Icons.open_in_new_rounded, color: VirilColors.gold, size: 16),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: league.color, width: 1.7),
            gradient: const LinearGradient(colors: [Color(0xFF4B402D), Color(0xFF171923)])),
            child: Icon(Icons.military_tech_rounded, color: league.color, size: 30)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(league.name, style: TextStyle(color: league.color, fontSize: 23, fontWeight: FontWeight.w900)),
            Text(league.description, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          ])),
          const Text('СЕЗОН', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.1)),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          _LeagueValue(label: 'МЕСТО В ЛИГЕ', value: '—'),
          const SizedBox(width: 20),
          _LeagueValue(label: 'ТЕКУЩИЙ СЕЗОН', value: '${stats.xp} XP*'),
          const SizedBox(width: 20),
          const _LeagueValue(label: 'ПРОШЛЫЙ СЕЗОН', value: '—'),
        ]),
        const SizedBox(height: 11),
        Text('* Пока показывается локальный XP. Мировое место и сезонная история появятся после подключения аккаунтов и сервера.',
          style: TextStyle(color: VirilColors.muted.withValues(alpha: .9), fontSize: 9, height: 1.4)),
        const SizedBox(height: 10),
        const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('ОТКРЫТЬ ЛИГУ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
          SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: VirilColors.gold, size: 15),
        ]),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900));

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: ProfileStore.instance.name);
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: VirilColors.stone,
      title: const Text('Твой никнейм'),
      content: TextField(controller: controller, autofocus: true, maxLength: 24,
        decoration: const InputDecoration(hintText: 'Введи никнейм')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Сохранить')),
      ],
    ));
    if (value != null) await ProfileStore.instance.updateProfile(name: value,
      bio: ProfileStore.instance.bio, avatarIndex: ProfileStore.instance.avatarIndex);
    controller.dispose();
  }

  Future<void> _openFaq(BuildContext context) async => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _FaqScreen()));
  Future<void> _showRegistrationInfo(BuildContext context) async => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
    backgroundColor: VirilColors.stone, title: const Text('Регистрация через Google'),
    content: const Text('Игровые аккаунты и синхронизация между устройствами ещё не подключены. Сейчас профиль и прогресс хранятся локально на этом устройстве. Подключение Google будет добавлено отдельным этапом.'),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Понятно'))]));
  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: 'VirilSupport@gmail.com',
      queryParameters: {'subject': 'Поддержка Viril'});
    await launchExternal(context, uri);
  }
  Future<void> _openTelegram(BuildContext context) async =>
      launchExternal(context, Uri.parse('https://t.me/Virilgo'));

  static IconData _avatarFor(int index) => [
    Icons.person_rounded, Icons.psychology_alt_rounded, Icons.shield_rounded,
    Icons.auto_awesome_rounded, Icons.emoji_events_rounded, Icons.explore_rounded,
  ][index.clamp(0, 5)];
  static _League _leagueFor(int xp) {
    if (xp >= 2000) return const _League('Обсидиан', 'Элитный этап личного пути', VirilColors.violet);
    if (xp >= 1000) return const _League('Золото', 'Высокая стабильность и дисциплина', VirilColors.gold);
    if (xp >= 500) return const _League('Серебро', 'Уверенное движение вперёд', VirilColors.ice);
    return const _League('Бронза', 'Начало большого пути', VirilColors.lava);
  }
}

Future<void> launchExternal(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть приложение. Проверь, установлено ли нужное приложение.')));
  }
}

class _League { const _League(this.name, this.description, this.color); final String name, description; final Color color; }
class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value, required this.label});
  final IconData icon; final String value, label;
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, size: 17, color: VirilColors.gold), const SizedBox(height: 5),
    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 7, color: VirilColors.muted, letterSpacing: .7, fontWeight: FontWeight.w800)),
  ]));
}
class _LeagueValue extends StatelessWidget {
  const _LeagueValue({required this.label, required this.value});
  final String label, value;
  @override Widget build(BuildContext context) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirilColors.muted, fontSize: 7, letterSpacing: .6)),
    const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
  ]));
}
class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17),
      border: Border.all(color: VirilColors.line)),
    child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(17), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      leading: Icon(icon, color: VirilColors.gold, size: 23),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: VirilColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded, color: VirilColors.muted))),
  );
}

class _FaqScreen extends StatelessWidget {
  const _FaqScreen();
  static const _items = <(String, String)>[
    ('Что такое Viril?', 'Viril — приложение для комплексного саморазвития. Оно помогает организовывать задачи, привычки и личные цели.'),
    ('Как начисляется XP?', 'Опыт начисляется за выполнение задач и доступные действия в разделах приложения. Значения отображаются в твоём локальном профиле.'),
    ('Что такое активные дни?', 'Это количество календарных дней, в которые приложение зафиксировало активность.'),
    ('Как работает уровень?', 'Уровень рассчитывается на основе накопленного XP. Сейчас расчёт выполняется на устройстве.'),
    ('Как работает Глобальная лига?', 'Экран лиги подготовлен, но мировой рейтинг появится после подключения регистрации, сервера и синхронизации результатов.'),
    ('Можно ли пользоваться без регистрации?', 'Да. Сейчас профиль и прогресс доступны локально без Google-аккаунта.'),
    ('Как изменить никнейм?', 'Открой профиль и нажми «Изменить никнейм» под именем.'),
    ('Как поменять язык?', 'Открой настройки профиля и выбери раздел «Язык». Сохранённый язык будет использоваться как предпочтение приложения; полная локализация экранов подключается поэтапно.'),
    ('Как сбросить прогресс?', 'В настройках профиля выбери «Сброс прогресса». Приложение попросит подтвердить действие перед удалением локальных результатов.'),
    ('Как связаться с поддержкой?', 'Используй кнопку «Поддержка» в профиле или напиши на VirilSupport@gmail.com.'),
    ('Где получить помощь в Telegram?', 'Нажми «Менеджер TG» в профиле, чтобы открыть контакт @Virilgo.'),
  ];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Ответы на вопросы'), backgroundColor: VirilColors.voidBlack),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('ПОМОЩЬ VIRIL', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      for (final item in _items) Card(color: VirilColors.stone, child: ExpansionTile(
        iconColor: VirilColors.gold, collapsedIconColor: VirilColors.muted,
        title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Align(alignment: Alignment.centerLeft, child: Text(item.$2,
          style: const TextStyle(color: VirilColors.muted, height: 1.5, fontSize: 12)))],
      )),
    ]),
  );
}
