import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';
import 'data/profile_store.dart';

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
      final seasonProgress = stats.xp % 500;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const SectionTitle('Профиль', subtitle: 'Твоя личная территория развития'),
          GlassCard(padding: const EdgeInsets.all(0), child: Column(children: [
            Container(height: 145, decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF263653), Color(0xFF171827), Color(0xFF473329)]),
            ), child: Stack(children: [
              Positioned(right: 20, top: 15, child: Icon(Icons.account_balance, size: 90, color: VirilColors.gold.withValues(alpha: .18))),
              const Positioned(left: 20, bottom: 18, child: Text('VIRIL · YOUR PATH', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontWeight: FontWeight.w800, fontSize: 10))),
            ])),
            Padding(padding: const EdgeInsets.all(18), child: Column(children: [
              Row(children: [
                Container(width: 66, height: 66, decoration: BoxDecoration(shape: BoxShape.circle,
                  color: VirilColors.stoneLight, border: Border.all(color: VirilColors.gold, width: 1.5)),
                  child: Icon(_avatarFor(profile.avatarIndex), color: VirilColors.ice, size: 34)),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21)),
                  Text('Уровень ${stats.level} · ${league.name}', style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
                  Text(profile.bio, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirilColors.gold, fontSize: 10)),
                ])),
                IconButton(onPressed: _editProfile, tooltip: 'Редактировать профиль',
                  icon: const Icon(Icons.edit_rounded, color: VirilColors.ice)),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: MetricTile(value: '${stats.xp}', label: 'ОБЩИЙ XP')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '$seasonProgress', label: 'XP СЕЗОНА')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${stats.completedCount}', label: 'ЗАДАЧ')),
              ]),
            ])),
          ])),
          const SectionTitle('Глобальная лига', subtitle: 'Твой личный сезонный путь'),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.emoji_events_rounded, color: VirilColors.gold, size: 26),
              const SizedBox(width: 9),
              const Expanded(child: Text('VIRIL · WORLD LEAGUE', style: TextStyle(color: VirilColors.gold, letterSpacing: 1.3, fontSize: 10, fontWeight: FontWeight.w800))),
              Text('СЕЗОН 01', style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
            ]),
            const SizedBox(height: 13),
            Row(children: [
              Expanded(child: Text(league.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
              Container(width: 52, height: 52, decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: league.color, width: 2),
                boxShadow: [BoxShadow(color: league.color.withValues(alpha: .18), blurRadius: 16)],
              ), child: Icon(Icons.military_tech_rounded, color: league.color, size: 27)),
            ]),
            const SizedBox(height: 4),
            Text(league.description, style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 14),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(
              value: seasonProgress / 500, minHeight: 8,
              backgroundColor: VirilColors.line,
              valueColor: AlwaysStoppedAnimation(league.color),
            )),
            const SizedBox(height: 7),
            Text('$seasonProgress / 500 XP в текущем цикле · ${500 - seasonProgress} XP до следующего этапа',
              style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
            const SizedBox(height: 14),
            const Text('Лиги рассчитываются локально по твоему опыту. Глобальный рейтинг появится после подключения серверных аккаунтов.',
              style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
          ])),
          const SectionTitle('Настройки'),
          _SettingsTile(icon: Icons.person_outline, title: 'Личные данные', subtitle: 'Имя, описание и аватар', onTap: _editProfile),
          _SettingsTile(icon: Icons.tune_rounded, title: 'Персонализация', subtitle: 'Настрой свой профиль', onTap: _editProfile),
          const _SettingsTile(icon: Icons.notifications_none, title: 'Уведомления', subtitle: 'Будут доступны после добавления уведомлений'),
          const _SettingsTile(icon: Icons.security_rounded, title: 'Конфиденциальность', subtitle: 'Данные профиля хранятся локально на устройстве'),
          const _SettingsTile(icon: Icons.help_outline, title: 'О приложении', subtitle: 'Viril · система комплексного саморазвития'),
        ],
      );
    },
  );

  Future<void> _editProfile() async {
    final profile = ProfileStore.instance;
    final name = TextEditingController(text: profile.name);
    final bio = TextEditingController(text: profile.bio);
    var avatar = profile.avatarIndex;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VirilColors.stone,
          title: const Text('Твой профиль'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Wrap(spacing: 8, children: List.generate(6, (index) => InkWell(
              onTap: () => setDialogState(() => avatar = index),
              child: Container(width: 43, height: 43, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatar == index ? VirilColors.ice.withValues(alpha: .2) : VirilColors.stoneLight,
                border: Border.all(color: avatar == index ? VirilColors.ice : VirilColors.line),
              ), child: Icon(_avatarFor(index), color: VirilColors.gold)),
            ))),
            const SizedBox(height: 14),
            TextField(controller: name, maxLength: 24, decoration: const InputDecoration(labelText: 'Имя')),
            TextField(controller: bio, maxLength: 70, decoration: const InputDecoration(labelText: 'Девиз или описание')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            FilledButton(onPressed: () async {
              await profile.updateProfile(name: name.text, bio: bio.text, avatarIndex: avatar);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            }, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    name.dispose();
    bio.dispose();
  }

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

class _League {
  const _League(this.name, this.description, this.color);
  final String name, description;
  final Color color;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GlassCard(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: InkWell(onTap: onTap, child: Row(children: [
      Icon(icon, color: VirilColors.ice),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ])),
      const Icon(Icons.chevron_right, color: VirilColors.muted),
    ])),
  );
}
