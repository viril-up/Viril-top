import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/viril_audio_service.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import 'data/profile_store.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}
class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  static const _languages = <String>[
    'Русский','Украинский','Английский','Французский','Немецкий','Испанский',
    'Китайский','Корейский','Японский','Индийский (хинди)','Арабский','Турецкий','Туркменский',
  ];
  String _language = 'Русский';
  bool _loaded = false;
  @override void initState() { super.initState(); _loadLanguage(); }
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _language = prefs.getString('viril.profile.language.v1') ?? 'Русский'; _loaded = true; });
  }
  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(context: context, backgroundColor: VirilColors.stone,
      isScrollControlled: true, builder: (ctx) => SafeArea(child: SizedBox(height: MediaQuery.of(ctx).size.height * .72,
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(18), child: Text('ЯЗЫК ПРИЛОЖЕНИЯ',
            style: TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, letterSpacing: 1.6))),
          Expanded(child: ListView(children: [for (final language in _languages)
            RadioListTile<String>(value: language, groupValue: _language, activeColor: VirilColors.gold,
              title: Text(language), onChanged: (v) => Navigator.pop(ctx, v))])),
        ]))));
    if (selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viril.profile.language.v1', selected);
    if (mounted) setState(() => _language = selected);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Языковое предпочтение сохранено. Полная локализация всех разделов будет подключаться поэтапно.')));
  }
  @override Widget build(BuildContext context) => Scaffold(
    
    appBar: AppBar(title: const Text('Настройки'), ),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 40), children: [
      const _GroupTitle('АТМОСФЕРА'),
      const _MusicSettingsCard(),
      const SizedBox(height: 16),
      const _GroupTitle('ПЕРСОНАЛИЗАЦИЯ'),
      _SettingTile(icon: Icons.language_rounded, title: 'Язык', subtitle: _loaded ? _language : 'Загрузка…', onTap: _chooseLanguage),
      const SizedBox(height: 16),
      const _GroupTitle('УПРАВЛЕНИЕ ДАННЫМИ'),
      _SettingTile(icon: Icons.restart_alt_rounded, title: 'Сброс прогресса',
        subtitle: 'Удалить XP, задачи, активность и записи', color: VirilColors.lava, onTap: _confirmReset),
      _SettingTile(icon: Icons.delete_forever_rounded, title: 'Удаление аккаунта',
        subtitle: 'Удалить локальный профиль и прогресс', color: VirilColors.lava, onTap: _confirmDelete),
      const SizedBox(height: 16),
      const _GroupTitle('ИНФОРМАЦИЯ'),
      _SettingTile(icon: Icons.lock_outline_rounded, title: 'Конфиденциальность',
        subtitle: 'Как хранятся и используются данные', onTap: _privacy),
      _SettingTile(icon: Icons.info_outline_rounded, title: 'О приложении',
        subtitle: 'Версия, назначение и контакты', onTap: _about),
    ]),
  );
  Future<void> _confirmReset() async {
    final yes = await _confirm(title: 'Сбросить прогресс?', message:
      'Будут удалены накопленный XP, задачи, отметки активности, записи дневника и благодарности. Никнейм и настройки профиля останутся.');
    if (yes != true) return;
    await VirilStore.instance.resetProgress();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Локальный прогресс сброшен.')));
  }
  Future<void> _confirmDelete() async {
    final yes = await _confirm(title: 'Удалить локальный профиль?', message:
      'Google-аккаунт в приложении пока не подключён. Это действие удалит локальный никнейм, описание, настройки профиля и весь прогресс с этого устройства. Восстановить данные будет нельзя.');
    if (yes != true) return;
    await VirilStore.instance.resetProgress();
    await ProfileStore.instance.resetLocalProfile();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('viril.profile.language.v1');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Локальные данные профиля удалены.')));
    Navigator.of(context).pop();
  }
  Future<bool?> _confirm({required String title, required String message}) => showDialog<bool>(context: context,
    builder: (ctx) => AlertDialog(backgroundColor: VirilColors.stone, title: Text(title),
      content: Text(message, style: const TextStyle(height: 1.45)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: VirilColors.lavaDeep),
          onPressed: () => Navigator.pop(ctx, true), child: const Text('Подтвердить')),
      ]));
  void _privacy() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _InfoPage(
    title: 'Конфиденциальность', sections: [
      ('Локальное хранение', 'На текущем этапе задачи, XP и данные профиля сохраняются локально на устройстве с помощью SharedPreferences.'),
      ('Передача данных', 'Регистрация через Google и серверная синхронизация пока не подключены. Мировой рейтинг не получает персональные данные, так как серверная лига ещё не запущена.'),
      ('Удаление', 'Локальные данные можно сбросить или удалить через настройки. Удаление приложения также может удалить локальные данные в зависимости от устройства.'),
      ('Контакты', 'По вопросам конфиденциальности: VirilSupport@gmail.com.'),
    ])));
  void _about() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _InfoPage(
    title: 'О приложении', sections: [
      ('Viril', 'Viril — система комплексного саморазвития, дисциплины и целей.'),
      ('Версия', 'Версия приложения: 1.0.0.'),
      ('Разделы', 'Главная, Развитие, Ресурсы, Прогресс и Профиль.'),
      ('Поддержка', 'VirilSupport@gmail.com · Telegram: @Virilgo.'),
    ])));
}
class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text); final String text;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10, left: 3),
    child: Text(text, style: const TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900)));
}
class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.color});
  final IconData icon; final String title, subtitle; final VoidCallback onTap; final Color? color;
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
    child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(16), child: ListTile(onTap: onTap, leading: Icon(icon, color: color ?? VirilColors.gold),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      trailing: const Icon(Icons.chevron_right_rounded, color: VirilColors.muted))));
}
class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.title, required this.sections});
  final String title; final List<(String,String)> sections;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), ),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      for (final section in sections) Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17), border: Border.all(color: VirilColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(section.$1, style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8), Text(section.$2, style: const TextStyle(color: VirilColors.muted, height: 1.5, fontSize: 12)),
        ])),
    ]));
}


class _MusicSettingsCard extends StatelessWidget {
  const _MusicSettingsCard();

  @override
  Widget build(BuildContext context) {
    final music = VirilAudioService.instance;
    return AnimatedBuilder(
      animation: music,
      builder: (context, _) => Container(
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
        decoration: BoxDecoration(
          color: VirilColors.stone,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VirilColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: VirilColors.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note_rounded, color: VirilColors.gold),
              ),
              const SizedBox(width: 11),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Фоновая музыка', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  SizedBox(height: 3),
                  Text('Тихая ambient-атмосфера', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
                ],
              )),
              Switch.adaptive(
                value: music.enabled,
                activeColor: VirilColors.gold,
                onChanged: (value) { music.setEnabled(value); },
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.volume_down_rounded, color: VirilColors.muted, size: 18),
              Expanded(child: Slider(
                value: music.volume,
                min: 0,
                max: 1,
                divisions: 20,
                activeColor: VirilColors.gold,
                inactiveColor: VirilColors.line,
                onChanged: music.enabled ? (value) { music.setVolume(value); } : null,
              )),
              const Icon(Icons.volume_up_rounded, color: VirilColors.muted, size: 18),
              const SizedBox(width: 7),
              SizedBox(
                width: 34,
                child: Text('${(music.volume * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: VirilColors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text('Громкость сохраняется автоматически. Музыка приостанавливается, когда приложение свёрнуто.',
                style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
