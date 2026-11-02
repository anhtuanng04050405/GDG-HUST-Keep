import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class LoginScreen extends StatefulWidget {
  final String currentTheme;
  final String currentColor;
  final OnThemeColorChanged onThemeChanged;

  const LoginScreen({
    super.key,
    required this.currentTheme,
    required this.currentColor,
    required this.onThemeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // Giả lập xử lý đăng nhập ngắn tạo cảm giác mượt mà
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (username == 'admin' && password == '123') {
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentTheme: widget.currentTheme,
              currentColor: widget.currentColor,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tài khoản hoặc mật khẩu không chính xác!';
        });
      }
    });
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
                      // Header image
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 16, 35, 12),
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/login/header.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'GDG KEEP',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tiêu đề Đăng nhập
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Vui lòng nhập tài khoản của bạn để tiếp tục',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form đăng nhập
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Tên đăng nhập',
                                  hintText: 'Nhập tên đăng nhập',
                                  prefixIcon: const Icon(Icons.person_outline),
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
                                    return 'Vui lòng nhập tên đăng nhập';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password field
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
                                const SizedBox(height: 12),
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

                              const SizedBox(height: 24),

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
                            ],
                          ),
                        ),
                      ),

                      // Spacer to push footer to the bottom
                      const Spacer(),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Thực hiện bởi:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: footerTitleColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nhóm 2 - Probation Mobile Gen 6',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: footerSubtitleColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
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
