import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class DiaryToolsCard extends StatelessWidget {
  const DiaryToolsCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _CompactHomeLauncher(
    title: 'Дневник',
    subtitle: '',
    icon: Icons.auto_stories_rounded,
    onTap: onTap,
  );
}

class _CompactHomeLauncher extends StatelessWidget {
  const _CompactHomeLauncher({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        radius: 14,
        child: SizedBox(
          height: 48,
          child: Row(children: [
          Icon(icon, color: VirilColors.ice, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              if (subtitle.isNotEmpty) Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: VirilColors.muted, fontSize: 8)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded, color: VirilColors.muted, size: 17),
          ]),
        ),
      ),
    ),
  );
}

enum _DiarySection { thoughts, audio, gratitude }

class DiaryToolsPage extends StatefulWidget {
  const DiaryToolsPage({super.key});

  @override
  State<DiaryToolsPage> createState() => _DiaryToolsPageState();
}

class _DiaryToolsPageState extends State<DiaryToolsPage> {
  static const _audioKey = 'viril.audio_entries.v1';
  final _textController = TextEditingController();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final List<Uint8List> _audioChunks = [];
  StreamSubscription<Uint8List>? _audioSubscription;
  List<Map<String, String>> _audioEntries = [];
  _DiarySection _section = _DiarySection.thoughts;
  DateTime _selectedDate = DateTime.now();
  bool _recording = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _loadAudioEntries();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _loadAudioEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_audioKey);
    if (raw == null) return;
    try {
      final decoded = (jsonDecode(raw) as List).cast<Map>();
      _audioEntries = decoded.map((e) => Map<String, String>.from(e)).toList();
      if (mounted) setState(() {});
    } catch (_) {
      _audioEntries = [];
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<Map<String, String>> get _visibleTextEntries {
    final entries = _section == _DiarySection.gratitude
        ? VirilStore.instance.gratitudeEntries
        : VirilStore.instance.journalEntries;
    return entries.where((entry) {
      final date = DateTime.tryParse(entry['createdAt'] ?? '');
      return date != null && _dateKey(date) == _dateKey(_selectedDate);
    }).toList();
  }

  List<Map<String, String>> get _visibleAudioEntries => _audioEntries.where((entry) {
    final date = DateTime.tryParse(entry['createdAt'] ?? '');
    return date != null && _dateKey(date) == _dateKey(_selectedDate);
  }).toList();

  Future<void> _saveText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_section == _DiarySection.gratitude) {
      await VirilStore.instance.saveGratitude(text);
    } else {
      await VirilStore.instance.saveJournalEntry(text);
    }
    _textController.clear();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись сохранена')),
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      await _recorder.stop();
      final pcm = BytesBuilder(copy: false);
      for (final chunk in _audioChunks) {
        pcm.add(chunk);
      }
      final wav = _wavBytes(pcm.takeBytes(), sampleRate: 44100, channels: 1);
      if (wav.length > 44) {
        final entry = <String, String>{
          'data': base64Encode(wav),
          'createdAt': DateTime.now().toIso8601String(),
        };
        _audioEntries.insert(0, entry);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_audioKey, jsonEncode(_audioEntries));
      }
      _audioChunks.clear();
      if (mounted) setState(() => _recording = false);
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (mounted) _showMessage('Нет доступа к микрофону. Разреши приложению использовать микрофон в настройках браузера или устройства.');
      return;
    }
    try {
      _audioChunks.clear();
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      ));
      _audioSubscription = stream.listen(_audioChunks.add);
      if (mounted) setState(() => _recording = true);
    } catch (error) {
      if (mounted) _showMessage('Не удалось начать запись: $error');
    }
  }

  Uint8List _wavBytes(Uint8List pcm, {required int sampleRate, required int channels}) {
    final bytes = ByteData(44 + pcm.length);
    void writeText(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }
    writeText(0, 'RIFF');
    bytes.setUint32(4, 36 + pcm.length, Endian.little);
    writeText(8, 'WAVE');
    writeText(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * channels * 2, Endian.little);
    bytes.setUint16(32, channels * 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeText(36, 'data');
    bytes.setUint32(40, pcm.length, Endian.little);
    bytes.buffer.asUint8List().setRange(44, 44 + pcm.length, pcm);
    return bytes.buffer.asUint8List();
  }

  Future<void> _playAudio(Map<String, String> entry) async {
    try {
      if (_playing) {
        await _player.stop();
        setState(() => _playing = false);
      }
      final bytes = base64Decode(entry['data'] ?? '');
      await _player.play(BytesSource(bytes));
      if (mounted) setState(() => _playing = true);
    } catch (error) {
      _showMessage('Не удалось воспроизвести запись: $error');
    }
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Выбери день для просмотра записей',
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _showInfo() {
    final details = switch (_section) {
      _DiarySection.thoughts => ('Дневник мыслей', 'Записывай идеи, переживания и выводы. Регулярные записи помогают лучше понимать себя, замечать повторяющиеся мысли и отслеживать личные изменения.'),
      _DiarySection.audio => ('Запись аудио', 'Записывай голосовые заметки, когда удобнее говорить, чем печатать. Записи сохраняются на этом устройстве и доступны в истории выбранного дня.'),
      _DiarySection.gratitude => ('Благодарность за всё', 'Отмечай то, за что благодарен сегодня. Это помогает замечать хорошие события и людей, которые поддерживают тебя.'),
    };
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: VirilColors.stone,
      title: Text(details.$1),
      content: Text(details.$2),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Понятно'))],
    ));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _sectionName(_DiarySection section) => switch (section) {
    _DiarySection.thoughts => 'Дневник',
    _DiarySection.audio => 'Запись аудио',
    _DiarySection.gratitude => 'Благодарность',
  };

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Дневник'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: AnimatedBuilder(
          animation: VirilStore.instance,
          builder: (context, _) => GlassCard(
            radius: 20,
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                const Expanded(child: Text('Твои личные записи', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'История записей за выбранный день',
                  onPressed: _chooseDate,
                  icon: const Icon(Icons.calendar_month_rounded, color: VirilColors.ice, size: 19),
                ),
              ]),
              Row(children: [
                for (final section in _DiarySection.values)
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _sectionTab(section),
                  )),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text(
                  '${_sectionName(_section)} · ${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                  style: const TextStyle(color: VirilColors.muted, fontSize: 9, fontWeight: FontWeight.w700),
                )),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Для чего этот раздел?',
                  onPressed: _showInfo,
                  icon: const Icon(Icons.priority_high_rounded, color: VirilColors.gold, size: 19),
                ),
              ]),
              if (_section == _DiarySection.audio) _audioContent() else _textContent(),
            ]),
          ),
        ),
      ),
    ),
  );

  Widget _sectionTab(_DiarySection section) {
    final selected = _section == section;
    final icon = switch (section) {
      _DiarySection.thoughts => Icons.menu_book_rounded,
      _DiarySection.audio => Icons.mic_none_rounded,
      _DiarySection.gratitude => Icons.favorite_border_rounded,
    };
    return Material(
      color: selected ? VirilColors.ice.withValues(alpha: .15) : VirilColors.stoneLight.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => _section = section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? VirilColors.ice.withValues(alpha: .5) : VirilColors.line),
          ),
          child: Column(children: [
            Icon(icon, size: 17, color: selected ? VirilColors.ice : VirilColors.muted),
            const SizedBox(height: 3),
            Text(_sectionName(section), maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                color: selected ? VirilColors.ice : VirilColors.muted)),
          ]),
        ),
      ),
    );
  }

  Widget _textContent() {
    final entries = _visibleTextEntries;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        controller: _textController,
        minLines: 2,
        maxLines: 3,
        maxLength: 1200,
        decoration: InputDecoration(
          hintText: _section == _DiarySection.gratitude
              ? 'За что ты благодарен сегодня?'
              : 'Запиши свои мысли, идеи и выводы...',
          counterText: '',
          filled: true,
          fillColor: VirilColors.stoneLight.withValues(alpha: .35),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(10),
        ),
        style: const TextStyle(fontSize: 11),
      ),
      Align(alignment: Alignment.centerRight, child: FilledButton.icon(
        onPressed: _saveText,
        icon: const Icon(Icons.save_rounded, size: 15),
        label: const Text('Сохранить', style: TextStyle(fontSize: 10)),
      )),
      _historyHeader(entries.length),
      if (entries.isEmpty)
        const Text('За этот день записей пока нет.', style: TextStyle(color: VirilColors.muted, fontSize: 9))
      else
        ...entries.take(2).map((entry) => _entryTile(entry)),
    ]);
  }

  Widget _audioContent() {
    final entries = _visibleAudioEntries;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(
          _recording ? 'Идёт запись…' : 'Голосовая заметка',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        )),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _recording ? VirilColors.lava : VirilColors.violet),
          onPressed: _toggleRecording,
          icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded, size: 16),
          label: Text(_recording ? 'Завершить' : 'Записать', style: const TextStyle(fontSize: 10)),
        ),
      ]),
      const SizedBox(height: 5),
      const Text('Аудиозаметки хранятся на этом устройстве. Для записи потребуется разрешение на микрофон.',
        style: TextStyle(color: VirilColors.muted, fontSize: 9)),
      _historyHeader(entries.length),
      if (entries.isEmpty)
        const Text('За этот день аудиозаписей пока нет.', style: TextStyle(color: VirilColors.muted, fontSize: 9))
      else
        ...entries.take(3).map((entry) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.graphic_eq_rounded, color: VirilColors.violet, size: 19),
          title: Text(_formatTime(entry['createdAt']), style: const TextStyle(fontSize: 10)),
          trailing: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _playAudio(entry),
            icon: Icon(_playing ? Icons.stop_circle_outlined : Icons.play_circle_fill_rounded,
              color: VirilColors.ice),
          ),
        )),
    ]);
  }

  Widget _historyHeader(int count) => Padding(
    padding: const EdgeInsets.only(top: 7, bottom: 3),
    child: Row(children: [
      const Icon(Icons.history_rounded, size: 13, color: VirilColors.gold),
      const SizedBox(width: 4),
      const Text('ИСТОРИЯ ЗА ДЕНЬ', style: TextStyle(color: VirilColors.gold, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w900)),
      const Spacer(),
      Text('$count', style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
    ]),
  );

  Widget _entryTile(Map<String, String> entry) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text('• ${_formatTime(entry['createdAt'])}  ${entry['text'] ?? ''}',
      maxLines: 2, overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: VirilColors.text, fontSize: 9, height: 1.3)),
  );

  String _formatTime(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
