import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import 'data/profile_store.dart';
import 'global_league_screen.dart';
import 'data/global_league_data.dart';
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
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/profile_cover/profile-cover.jpg', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF626870), Color(0xFF242830), Color(0xFF08090C)])))),
        Positioned(right: 12, top: 10, child: IconButton(
          tooltip: 'Настройки профиля',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileSettingsScreen())),
          style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: .35),
            side: BorderSide(color: VirilColors.gold.withValues(alpha: .45))),
          icon: const Icon(Icons.settings_rounded, color: VirilColors.gold))),
        Positioned(left: 15, right: 12, top: 62, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .92, end: 1),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeInOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [VirilColors.gold.withValues(alpha: .42), VirilColors.stone, VirilColors.ice.withValues(alpha: .2)]),
                    border: Border.all(color: VirilColors.gold, width: 2),
                    boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .35), blurRadius: 17)],
                  ),
                  child: Center(child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
                    child: Icon(_avatarFor(profile.avatarIndex), key: ValueKey(profile.avatarIndex),
                      size: 34, color: VirilColors.gold),
                  )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text('УРОВЕНЬ ${stats.level}  ·  ${league.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 9, letterSpacing: 1.15, color: VirilColors.gold, fontWeight: FontWeight.w800)),
              ])),
              IconButton(
                tooltip: 'Изменить никнейм, цитату и аватар',
                onPressed: _editProfile,
                style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: .36),
                  side: BorderSide(color: VirilColors.ice.withValues(alpha: .5))),
                icon: const Icon(Icons.edit_rounded, color: VirilColors.ice, size: 19),
              ),
            ]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .32),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: .15)),
              ),
              child: Text(profile.bio.isEmpty ? 'Добавь свою личную цитату…' : '«${profile.bio}»',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.35, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 9),
            _lifetimeStats(stats),
          ],
        )),
      ]),
    );
  }

  Widget _lifetimeStats(VirilStore stats) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .48),
      borderRadius: BorderRadius.circular(15), border: Border.all(color: VirilColors.gold.withValues(alpha: .25))),
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

  Widget _statDivider() => Container(width: 1, height: 32, color: Colors.white24);

  Widget _leagueCard(BuildContext context, VirilStore stats, _League league) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GlobalLeagueScreen())),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [0, .18, .48, 1],
          colors: [Color(0x663A3F47), Color(0x38252B34), Color(0x1C11161E), Color(0x0806080C)]),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.shield_moon_rounded, color: VirilColors.gold, size: 22),
          const SizedBox(width: 9),
          const Expanded(child: Text('ГЛОБАЛЬНАЯ ЛИГА', style: TextStyle(color: VirilColors.gold, fontSize: 11,
            letterSpacing: 1.7, fontWeight: FontWeight.w900))),
          const Icon(Icons.open_in_new_rounded, color: VirilColors.gold, size: 16),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: league.color, width: 1.7),
            gradient: const LinearGradient(colors: [Color(0xFF253448), Color(0xFF19212B)])),
            child: Icon(Icons.military_tech_rounded, color: league.color, size: 24)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(league.name, style: TextStyle(color: league.color, fontSize: 19, fontWeight: FontWeight.w900)),
            Text(league.description, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          ])),
          const Text('СЕЗОН', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _LeagueValue(label: 'МЕСТО В ЛИГЕ', value: '—'),
          const SizedBox(width: 20),
          _LeagueValue(label: 'ТЕКУЩИЙ СЕЗОН', value: '${stats.xp} XP*'),
          const SizedBox(width: 20),
          const _LeagueValue(label: 'ПРОШЛЫЙ СЕЗОН', value: '—'),
        ]),
        const SizedBox(height: 7),
        Text('* Пока показывается локальный XP. Мировое место и сезонная история появятся после подключения аккаунтов и сервера.',
          style: TextStyle(color: VirilColors.muted.withValues(alpha: .9), fontSize: 9, height: 1.4)),
        const SizedBox(height: 6),
        const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('ОТКРЫТЬ ЛИГУ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
          SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: VirilColors.gold, size: 15),
        ]),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900));

  Future<void> _editProfile() async {
    final profile = ProfileStore.instance;
    final nameController = TextEditingController(text: profile.name);
    final quoteController = TextEditingController(text: profile.bio);
    var avatar = profile.avatarIndex;
    const avatarIcons = <IconData>[
      Icons.psychology_rounded, Icons.auto_awesome_rounded, Icons.fitness_center_rounded,
      Icons.self_improvement_rounded, Icons.menu_book_rounded, Icons.school_rounded,
      Icons.lightbulb_rounded, Icons.explore_rounded, Icons.shield_rounded,
      Icons.bolt_rounded, Icons.favorite_rounded, Icons.spa_rounded,
      Icons.track_changes_rounded, Icons.military_tech_rounded, Icons.waves_rounded,
      Icons.rocket_launch_rounded, Icons.nights_stay_rounded, Icons.public_rounded,
      Icons.diamond_rounded, Icons.emoji_events_rounded,
    ];
    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Мой профиль'),
        content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('НИКНЕЙМ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            TextField(controller: nameController, maxLength: 24, decoration: const InputDecoration(hintText: 'Твой никнейм')),
            const SizedBox(height: 12),
            const Text('ЛИЧНАЯ ЦИТАТА', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            TextField(controller: quoteController, maxLength: 110, maxLines: 2,
              decoration: const InputDecoration(hintText: 'Фраза, которая отражает твой путь')),
            const SizedBox(height: 14),
            const Text('ВЫБЕРИ СИМВОЛ АВАТАРА', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: avatarIcons.length,
              itemBuilder: (_, i) => InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => setDialogState(() => avatar = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  decoration: BoxDecoration(
                    color: avatar == i ? VirilColors.gold.withValues(alpha: .2) : VirilColors.stoneLight,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: avatar == i ? VirilColors.gold : VirilColors.line, width: avatar == i ? 1.6 : 1),
                  ),
                  child: Icon(avatarIcons[i], color: avatar == i ? VirilColors.gold : VirilColors.muted, size: 25),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('20 тематических образов: интеллект, физическая сила, осознанность, духовность, знания и другие направления.',
              style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
          ],
        ))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
        ],
      ),
    ));
    if (result == true) {
      await profile.updateProfile(name: nameController.text, bio: quoteController.text, avatarIndex: avatar);
    }
    nameController.dispose();
    quoteController.dispose();
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

  static IconData _avatarFor(int index) => const <IconData>[
    Icons.psychology_rounded, Icons.auto_awesome_rounded, Icons.fitness_center_rounded,
    Icons.self_improvement_rounded, Icons.menu_book_rounded, Icons.school_rounded,
    Icons.lightbulb_rounded, Icons.explore_rounded, Icons.shield_rounded,
    Icons.bolt_rounded, Icons.favorite_rounded, Icons.spa_rounded,
    Icons.track_changes_rounded, Icons.military_tech_rounded, Icons.waves_rounded,
    Icons.rocket_launch_rounded, Icons.nights_stay_rounded, Icons.public_rounded,
    Icons.diamond_rounded, Icons.emoji_events_rounded,
  ][index.clamp(0, 19)];
  static _League _leagueFor(int xp) {
    final index = GlobalLeagueData.leagueIndexForXp(xp);
    final name = GlobalLeagueData.allLeagues[index];
    return _League(name, 'Лига ${index + 1} из 60 · уровень ${GlobalLeagueData.levelForXp(xp)}', GlobalLeagueData.colorForLeague(index));
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
