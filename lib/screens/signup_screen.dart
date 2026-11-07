import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.signUp(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Trả về status cho login
      Navigator.pop(context, {
        'status': response.session == null ? 'verify' : 'created',
        'email': _emailController.text.trim(),
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Vui lòng kiểm tra lại thông tin.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể tạo tài khoản. Vui lòng thử lại.';
        _isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final footerTitleColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF243757);
    final footerSubtitleColor = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF5E6C84);

    final inputDecorationTheme = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.outline.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 44,
        title: const Text(
          'Tạo tài khoản',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16,
                  maxWidth: 420,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 45,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Đăng ký tài khoản GDG-HUST Keep',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecorationTheme.copyWith(
                        labelText: 'Tên người dùng',
                        hintText: 'Nhập tên người dùng',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên người dùng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecorationTheme.copyWith(
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        final validEmail = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email);

                        if (!validEmail) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecorationTheme.copyWith(
                        labelText: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mật khẩu cần ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // confirm password
                    TextFormField(
                      controller: _confirmController,
                      obscureText: !_showConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) _handleSignUp();
                      },
                      decoration: inputDecorationTheme.copyWith(
                        labelText: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
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
                          color: colors.errorContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colors.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: colors.onErrorContainer,
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

                    // signup button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
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
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Text(
                                'Tạo tài khoản',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quay lại màn hình đăng nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản?',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: Text(
                            'Đăng nhập ngay',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Footer
                    Column(
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

                    const SizedBox(height: 15),
                  ],
                ),
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
