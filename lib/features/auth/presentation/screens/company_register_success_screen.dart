import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyRegisterSuccessScreen extends StatefulWidget {
  const CompanyRegisterSuccessScreen({super.key});

  @override
  State<CompanyRegisterSuccessScreen> createState() =>
      _CompanyRegisterSuccessScreenState();
}

class _CompanyRegisterSuccessScreenState
    extends State<CompanyRegisterSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // -- Design tokens (consistentes con corporate_onboarding_screen) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _cyanDimColor = Color(0xFF00DAF3);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _outlineVariantColor = Color(0xFFC5C6CD);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Decoración de fondo: halo difuso cyan (equivalente al div .absolute.-top-32 del HTML)
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _cyanColor.withValues(alpha: 0.07),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    _buildGlassCard(),
                    const SizedBox(height: 28),
                    const _SuccessFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  CARD PRINCIPAL — equivalente al div .glass-panel del HTML
  // ------------------------------------------------------------------ //
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSuccessIcon(),
              const SizedBox(height: 32),
              _buildHeadlines(),
              const SizedBox(height: 32),
              _buildBentoGrid(),
              const SizedBox(height: 32),
              _buildPrimaryButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  ÍCONO DE ÉXITO CON GLOW
  // ------------------------------------------------------------------ //
  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _cyanColor.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
              color: _cyanColor.withValues(alpha: 0.28),
              blurRadius: 60,
              spreadRadius: -8,
            ),
          ],
        ),
        child: const Icon(
          Icons.check_circle_outline_rounded,
          size: 60,
          color: _cyanDimColor,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  TITULARES
  // ------------------------------------------------------------------ //
  Widget _buildHeadlines() {
    return const Column(
      children: [
        Text(
          'Company account\ncreated successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.8,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Welcome to the future of institutional water management. Your ledger is ready for initialization.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: _onSurfaceVariantColor,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  BENTO GRID — Identity Verified / Vault Initialized
  // ------------------------------------------------------------------ //
  Widget _buildBentoGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            icon: Icons.verified_user_outlined,
            label: 'Identity Verified',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBentoCard(
            icon: Icons.account_balance_outlined,
            label: 'Vault Initialized',
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _outlineVariantColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _secondaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTÓN PRIMARIO — Go to Dashboard
  // ------------------------------------------------------------------ //
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Go to Dashboard',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

}

// ------------------------------------------------------------------ //
//  FOOTER — fuera del card, en la parte inferior de la pantalla
// ------------------------------------------------------------------ //
class _SuccessFooter extends StatelessWidget {
  const _SuccessFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 15,
          color: const Color(0xFF44474D).withValues(alpha: 0.55),
        ),
        const SizedBox(width: 6),
        Text(
          'Secured by Institutional Grade Encryption',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF44474D).withValues(alpha: 0.55),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
