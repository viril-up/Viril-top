import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/viril_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isBusy = false;
  bool _obscurePassword = true;
  String? _notice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Аккаунт Viril')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shield_moon_rounded, color: VirilColors.gold, size: 54),
                  const SizedBox(height: 12),
                  const Text(
                    'ТВОЙ ПУТЬ НАЧИНАЕТСЯ ЗДЕСЬ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _isSignUp ? 'Создать аккаунт' : 'С возвращением',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Зарегистрируйся, чтобы в дальнейшем пользоваться личными сообщениями и синхронизацией.'
                        : 'Войди в свой аккаунт Viril.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: VirilColors.muted, fontSize: 12, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  if (!SupabaseService.isInitialized)
                    _message('Сервис авторизации пока недоступен. Проверь подключение и попробуй снова.', isError: true)
                  else ...[
                    OutlinedButton.icon(
                      onPressed: _isBusy ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 27),
                      label: const Text('Продолжить с Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: VirilColors.line),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Row(children: [
                        Expanded(child: Divider(color: VirilColors.line)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ИЛИ', style: TextStyle(color: VirilColors.subdued, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                        Expanded(child: Divider(color: VirilColors.line)),
                      ]),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: _decoration('Электронная почта', Icons.mail_outline_rounded),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
                                return 'Введи корректный email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: _decoration('Пароль', Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: VirilColors.muted),
                              ),
                            ),
                            validator: (value) {
                              final password = value ?? '';
                              if (password.length < 8) return 'Минимум 8 символов';
                              return null;
                            },
                          ),
                          if (_notice != null) ...[
                            const SizedBox(height: 12),
                            _message(_notice!),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: _isBusy ? null : _submitEmail,
                            style: FilledButton.styleFrom(
                              backgroundColor: VirilColors.gold,
                              foregroundColor: VirilColors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isBusy
                                ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(_isSignUp ? 'Создать аккаунт' : 'Войти', style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _isBusy ? null : () => setState(() {
                        _isSignUp = !_isSignUp;
                        _notice = null;
                      }),
                      child: Text(
                        _isSignUp ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться',
                        style: const TextStyle(color: VirilColors.ice, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Не передавай пароль другим людям. Viril никогда не попросит отправить его в чате.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: VirilColors.subdued, fontSize: 9, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: VirilColors.gold, size: 19),
    filled: true,
    fillColor: VirilColors.stone,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: VirilColors.line)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: VirilColors.line)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: VirilColors.gold, width: 1.3)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent)),
  );

  Widget _message(String text, {bool isError = false}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: (isError ? Colors.redAccent : VirilColors.ice).withValues(alpha: .09),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: (isError ? Colors.redAccent : VirilColors.ice).withValues(alpha: .25)),
    ),
    child: Text(text, style: TextStyle(color: isError ? Colors.redAccent.shade100 : VirilColors.ice, fontSize: 11, height: 1.4)),
  );

  String get _webRedirectUrl {
    final isGitHubPagesProjectSite = Uri.base.pathSegments.contains('Viril-top');
    final targetPath = isGitHubPagesProjectSite ? '/Viril-top/' : '/';
    return Uri.base.replace(path: targetPath, query: '', fragment: '').toString();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _notice = null;
    });
    try {
      final client = SupabaseService.client;
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isSignUp) {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: kIsWeb ? _webRedirectUrl : null,
        );
        if (!mounted) return;
        if (response.session != null) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isSignUp = false;
            _notice = 'Аккаунт создан. Проверь почту и подтверди адрес, затем войди в Viril.';
          });
        }
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
        if (mounted) Navigator.of(context).pop(true);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _notice = _friendlyError(error.message));
    } catch (_) {
      if (mounted) setState(() => _notice = 'Не удалось связаться с сервером. Проверь интернет и повтори попытку.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isBusy = true;
      _notice = null;
    });
    try {
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? _webRedirectUrl : 'io.supabase.viril://login-callback/',
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _notice = _friendlyError(error.message));
    } catch (_) {
      if (mounted) setState(() => _notice = 'Не удалось запустить вход через Google. Проверь настройки провайдера.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _friendlyError(String message) {
    final value = message.toLowerCase();
    if (value.contains('invalid login credentials')) return 'Неверная почта или пароль.';
    if (value.contains('already registered') || value.contains('user already registered')) return 'Этот email уже зарегистрирован. Попробуй войти.';
    if (value.contains('password should be at least')) return 'Пароль должен содержать не менее 8 символов.';
    if (value.contains('email not confirmed')) return 'Сначала подтверди email по ссылке из письма.';
    if (value.contains('provider is not enabled')) return 'Вход через Google ещё не включён в настройках Supabase.';
    return message;
  }
}
