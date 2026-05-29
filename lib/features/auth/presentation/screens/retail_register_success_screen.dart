import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RetailRegisterSuccessScreen extends StatefulWidget {
  const RetailRegisterSuccessScreen({super.key});

  @override
  State<RetailRegisterSuccessScreen> createState() =>
      _RetailRegisterSuccessScreenState();
}

class _RetailRegisterSuccessScreenState
    extends State<RetailRegisterSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // -- Design tokens (consistentes con el sistema de auth screens) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _greenColor = Color(0xFF469446); // on-tertiary-container
  static const _onSurfaceVariantColor = Color(0xFF44474D);
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
          // Blob superior derecho — equivalente a .absolute.-top-24.-right-24 del HTML
          Positioned(
            top: -96,
            right: -96,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyanColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Blob inferior izquierdo — equivalente a .absolute.bottom-1/4.-left-24 del HTML
          Positioned(
            bottom: 80,
            left: -96,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _secondaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          _buildIllustration(),
                          const SizedBox(height: 32),
                          _buildContent(),
                          const SizedBox(height: 32),
                          _buildBentoCards(),
                          const SizedBox(height: 32),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  ILUSTRACIÓN: círculo glassmorphism + water icon + badge check
  // ------------------------------------------------------------------ //
  Widget _buildIllustration() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 192,
        height: 192,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de vidrio principal
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.70),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _cyanColor.withValues(alpha: 0.12),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.water_drop,
                    size: 90,
                    color: _cyanColor,
                  ),
                ),
              ),
            ),
            // Badge verde de check — bottom-right
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _greenColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _greenColor.withValues(alpha: 0.4),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BADGE + HEADLINE + SUBTÍTULO
  // ------------------------------------------------------------------ //
  Widget _buildContent() {
    return Column(
      children: [
        // "REGISTRATION VERIFIED" pill badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _cyanColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'REGISTRATION VERIFIED',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _secondaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Retail investor account\ncreated successfully.',
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
        const SizedBox(height: 12),
        const Text(
          'Your portal to institutional-grade water assets and ESG impact is now active.',
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
  //  BENTO CARDS: Portfolio Status + ESG Tier
  // ------------------------------------------------------------------ //
  Widget _buildBentoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.water_drop_outlined,
            iconColor: _secondaryColor,
            label: 'Portfolio Status',
            value: 'Active',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.energy_savings_leaf_outlined,
            iconColor: _greenColor,
            label: 'ESG Tier',
            value: 'Silver',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _outlineVariantColor.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariantColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTONES — Go to Marketplace + View Onboarding Tutorial
  // ------------------------------------------------------------------ //
  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
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
                  'Go to Marketplace',
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
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: _secondaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            'View Onboarding Tutorial',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _secondaryColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  FOOTER — branding difuminado + tagline
  // ------------------------------------------------------------------ //
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Column(
        children: [
          Text(
            'Water Ledger',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primaryColor.withValues(alpha: 0.22),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Institutional Sustainable Finance',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _onSurfaceVariantColor.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
