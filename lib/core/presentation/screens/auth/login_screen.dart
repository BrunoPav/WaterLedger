import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // -- Design tokens extraídos de DESIGN.md / Stitch Template --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _outlineColor = Color(0xFF75777E);
  static const _onTertiaryContainerColor = Color(0xFF469446);
  static const _focusBorderColor = Color(0xFF00E3FD); // secondary-container

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá email y contraseña')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).login(email: email, password: password);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Blob decorativo superior-izquierdo (cyan/secondary-fixed)
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A9CF0FF),
              ),
            ),
          ),
          // Blob decorativo inferior-derecho (mint/tertiary-fixed)
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1AA3F69C), // 0x1A = 10% opacity
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
                    child: Column(
                      children: [
                        _buildBranding(),
                        const SizedBox(height: 32),
                        _buildLoginCard(),
                        const SizedBox(height: 32),
                        _buildTrustIndicators(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer fijo en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BRANDING
  // ------------------------------------------------------------------ //
  Widget _buildBranding() {
    return Column(
      children: [
        // Ícono con water_drop dentro de un contenedor negro redondeado
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Water Ledger',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.8,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure environmental asset management\nand institutional water trading.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _onSurfaceVariantColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  CARD DE LOGIN (glassmorphism)
  // ------------------------------------------------------------------ //
  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _outlineVariantColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Email ---
              _buildFieldLabel('EMAIL ADDRESS'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'name@institution.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // --- Password label + forgot ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('PASSWORD'),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _secondaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // --- Password field ---
              _buildTextField(
                controller: _passwordController,
                hintText: '••••••••',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _outlineColor,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),
              // --- Botón Login ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: _onPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // --- Divisor ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: _outlineVariantColor.withValues(alpha: 0.25),
                    thickness: 1,
                  ),
                  Container(
                    color: Colors.white.withValues(alpha: 0.72),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'INSTITUTIONAL ACCESS ONLY',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.65),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // --- Register link ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to the platform? ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: _onSurfaceVariantColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _secondaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS DE CARD
  // ------------------------------------------------------------------ //
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _onSurfaceVariantColor.withValues(alpha: 0.7),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: _onSurfaceColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _outlineColor, fontSize: 16),
        filled: true,
        fillColor: _surfaceContainerLowColor,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _focusBorderColor, width: 2),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  TRUST INDICATORS
  // ------------------------------------------------------------------ //
  Widget _buildTrustIndicators() {
    return Opacity(
      opacity: 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder logo ESG Certified
          Container(
            height: 24,
            width: 90,
            decoration: BoxDecoration(
              color: _outlineVariantColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'ESG Certified',
                style: TextStyle(fontSize: 9, color: _outlineColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 16, color: _outlineVariantColor),
          const SizedBox(width: 16),
          // Placeholder logo UN Water
          Container(
            height: 24,
            width: 90,
            decoration: BoxDecoration(
              color: _outlineVariantColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'UN Water',
                style: TextStyle(fontSize: 9, color: _outlineColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  FOOTER
  // ------------------------------------------------------------------ //
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
          top: BorderSide(
            color: _outlineVariantColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 16,
              color: _onTertiaryContainerColor,
            ),
            const SizedBox(width: 8),
            Text(
              'AES-256 Encrypted Environment',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
