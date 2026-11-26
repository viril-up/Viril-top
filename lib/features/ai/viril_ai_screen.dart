import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class VirilAiScreen extends StatefulWidget {
  const VirilAiScreen({super.key});

  @override
  State<VirilAiScreen> createState() => _VirilAiScreenState();
}

class _VirilAiScreenState extends State<VirilAiScreen> {
  static const _apiBaseUrl = String.fromEnvironment('VIRIL_AI_API_URL');
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content': 'Привет! Я Viril AI. Могу помочь разобраться в идеях, знаниях и целях. С чего начнём?',
    },
  ];
  bool _sending = false;

  bool get _isConfigured => _apiBaseUrl.trim().isNotEmpty;

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    _inputController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _sending = true;
    });
    _scrollToBottom();

    if (!_isConfigured) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Интерфейс Viril AI готов. Сервер ещё не подключён: после развёртывания Cloudflare Worker добавим его адрес в настройку VIRIL_AI_API_URL.',
        });
        _sending = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final uri = Uri.parse('${_apiBaseUrl.replaceAll(RegExp(r'/+$'), '')}/api/chat');
      final response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'messages': _messages
                  .where((message) => message['role'] == 'user' || message['role'] == 'assistant')
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map ? decoded['error']?.toString() : null;
        throw Exception(message ?? 'Ошибка сервера (${response.statusCode})');
      }
      final answer = decoded is Map
          ? (decoded['response'] ?? decoded['text'] ?? decoded['output_text'])?.toString()
          : null;
      if (answer == null || answer.trim().isEmpty) {
        throw Exception('Сервер вернул пустой ответ');
      }
      if (!mounted) return;
      setState(() => _messages.add({'role': 'assistant', 'content': answer.trim()}));
    } catch (error) {
      if (!mounted) return;
      setState(() => _messages.add({
        'role': 'assistant',
        'content': 'Не удалось получить ответ. Проверь подключение к интернету и настройки AI-сервера. Детали: $error',
      }));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _showVoiceInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Голосовой режим'),
        content: const Text(
          'Кнопка голосового режима появится здесь. Для полноценного общения голосом нужно отдельно подключить распознавание речи и озвучивание ответов AI. Сейчас готовится текстовый чат.',
          style: TextStyle(color: VirilColors.muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 4,
          title: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VirilColors.chartBlue.withValues(alpha: .14),
                  border: Border.all(color: VirilColors.chartBlue.withValues(alpha: .55)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: VirilColors.chartBlueLight, size: 19),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Viril AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('ТВОЙ AI-ПОМОЩНИК', style: TextStyle(fontSize: 8, letterSpacing: 1.2, color: VirilColors.muted)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Голосовой режим',
              onPressed: _showVoiceInfo,
              icon: const Icon(Icons.mic_none_rounded, color: VirilColors.chartBlueLight),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 15, 8),
                child: GlassCard(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        _isConfigured ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                        color: _isConfigured ? VirilColors.chartBlueLight : VirilColors.gold,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _isConfigured ? 'Подключение к AI-серверу настроено' : 'Демонстрационный режим · сервер ещё не подключён',
                          style: const TextStyle(color: VirilColors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 16),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_sending && index == _messages.length) {
                      return const _TypingIndicator();
                    }
                    final message = _messages[index];
                    return _ChatBubble(
                      text: message['content'] ?? '',
                      isUser: message['role'] == 'user',
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 7, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Голосовое общение',
                        onPressed: _showVoiceInfo,
                        icon: const Icon(Icons.mic_rounded, color: VirilColors.chartBlueLight),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Напиши Viril AI...',
                            filled: true,
                            fillColor: VirilColors.stone.withValues(alpha: .9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(color: VirilColors.line),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(color: VirilColors.line),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(color: VirilColors.chartBlue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Material(
                        color: VirilColors.chartBlue.withValues(alpha: .18),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Отправить',
                          onPressed: _sending ? null : _sendMessage,
                          icon: const Icon(Icons.arrow_upward_rounded, color: VirilColors.chartBlueLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) => Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isUser ? VirilColors.navyLight.withValues(alpha: .88) : VirilColors.stone.withValues(alpha: .94),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17),
              topRight: const Radius.circular(17),
              bottomLeft: Radius.circular(isUser ? 17 : 5),
              bottomRight: Radius.circular(isUser ? 5 : 17),
            ),
            border: Border.all(color: isUser ? VirilColors.chartBlue.withValues(alpha: .35) : VirilColors.line),
          ),
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.45, color: VirilColors.text)),
        ),
      );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Text('Viril AI печатает…', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
        ),
      );
}
