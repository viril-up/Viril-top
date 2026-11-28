import 'package:flutter/material.dart';
import '../../core/widgets/viril_staggered_list.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import 'data/profile_store.dart';
import 'global_league_screen.dart';
import 'widgets/league_emblem.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_frame.dart';
import 'data/global_league_data.dart';
import 'profile_settings_screen.dart';
import 'future_features_screen.dart';
import 'viril_store_screen.dart';
import '../community/community_screen.dart';
import '../auth/auth_screen.dart';

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
      return VirilStaggeredList(pageIndex: 4, 
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
        children: [
          _profileCover(profile, stats, league),
          const SizedBox(height: 14),
          _FutureProfileTile(
            icon: Icons.chat_bubble_rounded,
            title: 'Личные сообщения',
            accent: VirilColors.ice,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CommunityScreen(initialTab: 0)),
            ),
          ),
          const SizedBox(height: 5),
          _leagueCard(context, stats, league),
          const SizedBox(height: 12),
          _FutureProfileTile(
            icon: Icons.shopping_bag_rounded,
            title: 'Магазин',
            
            accent: VirilColors.gold,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VirilStoreScreen())),
          ),
          const SizedBox(height: 4),
          _FutureProfileTile(
            icon: Icons.emoji_events_rounded,
            title: 'Мотивационная игра',
            
            accent: VirilColors.gold,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MotivationGameScreen())),
          ),
          _FutureProfileTile(
            icon: Icons.redeem_rounded,
            title: 'Пригласить друга +',
            accent: VirilColors.ice,
            compact: true,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InviteFriendScreen())),
          ),
          const SizedBox(height: 16),
          _sectionLabel('ТВОЙ ПРОФИЛЬ'),
          const SizedBox(height: 10),
          _ActionTile(
            icon: profile.isSignedIn ? Icons.verified_user_rounded : Icons.person_add_alt_1_rounded,
            title: profile.isSignedIn ? 'Аккаунт подключён' : 'Войти / зарегистрироваться',
            subtitle: profile.isSignedIn
                ? '${profile.accountEmail.isEmpty ? profile.accountName : profile.accountEmail} · ID ${profile.userId}'
                : 'Google или электронная почта',
            onTap: () => profile.isSignedIn
                ? _manageAccount(context)
                : _openAuth(context),
          ),
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
    return CustomPaint(
      foregroundPainter: _ProfileMaskPainter(25),
      child: Container(
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
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
              ProfileAvatar(profile: profile, size: 68, iconSize: 30),
              const SizedBox(width: 12),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text('УРОВЕНЬ ${stats.level}  ·  ${league.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 9, letterSpacing: 1.15, color: VirilColors.gold, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('ID: ${profile.userId.isEmpty ? 'создаётся…' : profile.userId}',
                  style: const TextStyle(fontSize: 9, letterSpacing: .8, color: Colors.white70, fontWeight: FontWeight.w600)),
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
      ),
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
    child: CustomPaint(
      foregroundPainter: _ProfileMaskPainter(18),
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 7))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
          Positioned.fill(child: Image.asset(
            'assets/section_cards/global_league/global-league.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF303640), Color(0xFF11161E)]),
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('ГЛОБАЛЬНАЯ ЛИГА', style: TextStyle(color: VirilColors.gold, fontSize: 11,
            letterSpacing: 1.7, fontWeight: FontWeight.w900))),
          const Icon(Icons.open_in_new_rounded, color: VirilColors.gold, size: 16),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          LeagueEmblem(
            number: league.number,
            materialName: league.name,
            size: 40,
            unlocked: true,
            active: true,
          ),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(league.name, style: TextStyle(color: league.color, fontSize: 17, fontWeight: FontWeight.w900)),
            Text(league.description, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          ])),
          const Text('СЕЗОН', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.1)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _LeagueValue(label: 'МЕСТО В ЛИГЕ', value: '—'),
          const SizedBox(width: 20),
          _LeagueValue(label: 'ТЕКУЩИЙ СЕЗОН', value: '${stats.xp} XP'),
          const SizedBox(width: 20),
          const _LeagueValue(label: 'ПРОШЛЫЙ СЕЗОН', value: '—'),
        ]),

        const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('ОТКРЫТЬ ЛИГУ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
          SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: VirilColors.gold, size: 15),
        ]),
            ]),
          ),
        ]),
      ),
      ),
    ),
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900));

  Future<void> _editProfile() async {
    final profile = ProfileStore.instance;
    final nameController = TextEditingController(text: profile.name);
    final quoteController = TextEditingController(text: profile.bio);
    var avatar = profile.avatarIndex;
    var frame = profile.frameIndex;
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
              itemCount: avatarIcons.length + 1,
              itemBuilder: (_, i) {
                final selected = avatar == i - 1;
                return Tooltip(
                  message: i == 0 ? 'Без аватарки' : 'Выбрать аватар',
                  child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => setDialogState(() => avatar = i - 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    decoration: BoxDecoration(
                      color: selected ? VirilColors.gold.withValues(alpha: .2) : VirilColors.stoneLight,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: selected ? VirilColors.gold : VirilColors.line, width: selected ? 1.6 : 1),
                    ),
                    child: Icon(i == 0 ? Icons.person_off_rounded : avatarIcons[i - 1],
                      color: selected ? VirilColors.gold : VirilColors.muted, size: 25),
                  ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('ВЫБЕРИ РАМКУ ПРОФИЛЯ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: 2.65,
              ),
              itemCount: ProfileFrame.styles.length + 1,
              itemBuilder: (_, i) {
                final selected = frame == i - 1;
                return InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => setDialogState(() => frame = i - 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected ? VirilColors.gold.withValues(alpha: .12) : VirilColors.stoneLight,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: selected ? VirilColors.gold : VirilColors.line, width: selected ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      if (i == 0)
                        const SizedBox(width: 32, height: 32, child: Icon(Icons.circle_outlined, color: VirilColors.muted, size: 23))
                      else
                        ProfileFrame(frameIndex: i - 1, size: 32,
                          child: const Icon(Icons.auto_awesome_rounded, size: 15, color: Colors.white)),
                      const SizedBox(width: 7),
                      Expanded(child: Text(i == 0 ? 'Без рамки' : ProfileFrame.styles[i - 1].name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                          color: selected ? VirilColors.gold : VirilColors.text))),
                      if (selected) const Icon(Icons.check_circle_rounded, color: VirilColors.gold, size: 14),
                    ]),
                  ),
                );
              },
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
      final nickname = nameController.text.trim().replaceAll('@', '').toLowerCase();
      const demoNicknames = <String>{
        'artem', 'artem_01', 'maksim', 'maksim.fit', 'daniil', 'dan_vision',
        'timur', 'timur.focus', 'eldar', 'eldar_move', 'alex', 'alex.mind',
      };
      if (nickname.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Никнейм не может быть пустым.')));
      } else if (demoNicknames.contains(nickname)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Этот никнейм уже занят. Выбери другой.')));
      } else {
        await profile.updateProfile(name: nameController.text, bio: quoteController.text, avatarIndex: avatar, frameIndex: frame);
      }
    }
    nameController.dispose();
    quoteController.dispose();
  }

  Future<void> _openFaq(BuildContext context) async => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _FaqScreen()));
  Future<void> _openAuth(BuildContext context) async {
    final connected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
    if (connected == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аккаунт Viril успешно подключён.')),
      );
    }
  }

  Future<void> _manageAccount(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Аккаунт Viril'),
        content: Text(
          'Подключённый аккаунт: ${ProfileStore.instance.accountEmail}\nID: ${ProfileStore.instance.userId}\n\nВыйти, чтобы подключить другой аккаунт?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true) return;
    try {
      await ProfileStore.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы вышли из аккаунта.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось выйти. Проверь интернет и повтори попытку.')),
        );
      }
    }
  }
  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: 'VirilSupport@gmail.com',
      queryParameters: {'subject': 'Поддержка Viril'});
    await launchExternal(context, uri);
  }
  Future<void> _openTelegram(BuildContext context) async =>
      launchExternal(context, Uri.parse('https://t.me/Virilgo'));

  static _League _leagueFor(int xp) {
    final index = GlobalLeagueData.leagueIndexForXp(xp);
    final name = GlobalLeagueData.allLeagues[index];
    return _League(name, 'Лига ${index + 1} из 60 · уровень ${GlobalLeagueData.levelForXp(xp)}', GlobalLeagueData.colorForLeague(index), index + 1);
  }
}

Future<void> launchExternal(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть приложение. Проверь, установлено ли нужное приложение.')));
  }
}

class _League { const _League(this.name, this.description, this.color, this.number); final String name, description; final Color color; final int number; }
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
    
    appBar: AppBar(title: const Text('Ответы на вопросы'), ),
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


/// Top rim and upper side edges fade out smoothly toward the middle of each card.
class _ProfileMaskPainter extends CustomPainter {
  const _ProfileMaskPainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(.65), Radius.circular(radius)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, .16, .34, .52, .72, 1],
        colors: [
          Color(0x9AA6B3C1),
          Color(0x687D8998),
          Color(0x354B5664),
          Color(0x123D4855),
          Color(0x043D4855),
          Color(0x003D4855),
        ],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileMaskPainter oldDelegate) => oldDelegate.radius != radius;
}


class _FutureProfileTile extends StatelessWidget {
  const _FutureProfileTile({required this.icon, required this.title, required this.accent, required this.onTap, this.compact = false});
  final IconData icon;
  final String title;
  final Color accent;
  final VoidCallback onTap;
  final bool compact;

  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: .28))),
    child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(16),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 13, vertical: compact ? 8 : 11), child: Row(children: [
          Container(width: compact ? 34 : 39, height: compact ? 34 : 39,
            decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: accent, size: compact ? 19 : 21)),
          const SizedBox(width: 11),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
          Icon(Icons.chevron_right_rounded, color: accent, size: 20),
        ])),
      ),
    ),
  );
}
