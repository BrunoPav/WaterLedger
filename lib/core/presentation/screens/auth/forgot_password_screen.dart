import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/core/domain/validators/auth_validators.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  // -- Design tokens (mismos que login_screen) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _outlineColor = Color(0xFF75777E);
  static const _focusBorderColor = Color(0xFF00E3FD);
  static const _tertiaryFixedColor = Color(0xFFA3F69C);
  static const _onTertiaryFixedColor = Color(0xFF002204);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    // Validación cliente: formato de email antes de pegar Firebase.
    final error = AuthValidators.email(email);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
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
          // Blob decorativo (mismo estilo que login)
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
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHero(),
                        const SizedBox(height: 32),
                        _sent ? _buildSentCard() : _buildFormCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Top app bar liviana con back + título --- //
  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.1)),
            ),
          ),
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor),
                  ),
                  const Text(
                    'Recover Password',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 18),
        const Text(
          'Forgot your password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Enter your account email and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: _onSurfaceVariantColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariantColor,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: _onSurfaceColor,
                ),
                decoration: InputDecoration(
                  hintText: 'name@institution.com',
                  hintStyle: const TextStyle(color: _outlineColor, fontSize: 16),
                  filled: true,
                  fillColor: _surfaceContainerLowColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _focusBorderColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: _onPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista de éxito — confirma que el email fue enviado
  Widget _buildSentCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _tertiaryFixedColor,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: _onTertiaryFixedColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check your inbox',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'If an account exists for ${_emailController.text.trim()}, a reset link was just sent. The link expires in 1 hour.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: _onSurfaceVariantColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _sent = false),
                style: TextButton.styleFrom(foregroundColor: _secondaryColor),
                child: const Text(
                  'Send to a different email',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
