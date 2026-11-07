import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/note_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signIn(email: email, password: password);

      if (!mounted) return;

      NoteService.clearCache();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      final needsConfirmation = e.message.toLowerCase().contains('Email chưa được xác thực.');
      setState(() {
        _isLoading = false;
        _errorMessage = needsConfirmation
            ? 'Vui lòng xác nhận email trước khi đăng nhập.'
            : 'Vui lòng kiểm tra lại email và mật khẩu.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể đăng nhập. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _navigateToSignUp() async {
    setState(() {
      _errorMessage = null;
    });

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );

    if (!mounted || result == null) return;

    String? status;
    String? email;

    if (result is Map) {
      status = result['status']?.toString();
      email = result['email']?.toString();
    } else if (result is String) {
      status = result;
    }

    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
      _passwordController.clear();
    }

    if (status == 'verify') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Đăng ký thành công! Vui lòng kiểm tra email để xác nhận tài khoản trước khi đăng nhập.',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (status == 'created') {
      if (Supabase.instance.client.auth.currentSession != null) {
        NoteService.clearCache();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tạo tài khoản thành công! Bạn có thể đăng nhập ngay.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final footerTitleColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF243757);
    final footerSubtitleColor = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF5E6C84);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(

                    children: [

                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Image.asset(
                              'assets/login/header.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Tiêu đề Đăng nhập
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Form đăng nhập
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              // Email
                              TextFormField(
                                controller: _emailController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'example@email.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 15),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  hintText: 'Nhập mật khẩu',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  return null;
                                },
                              ),

                              // Error Message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: colorScheme.onErrorContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: colorScheme.onErrorContainer,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 15),

                              // Login button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Phần đăng ký tài khoản (Sign up)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Chưa có tài khoản? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _navigateToSignUp,
                                    child: Text(
                                      'Đăng ký ngay',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Thực hiện bởi:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: footerTitleColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Nhóm 2 - Probation Mobile Gen 6',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: footerSubtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
