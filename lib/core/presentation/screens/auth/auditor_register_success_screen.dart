import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuditorRegisterSuccessScreen extends StatefulWidget {
  const AuditorRegisterSuccessScreen({super.key});

  @override
  State<AuditorRegisterSuccessScreen> createState() =>
      _AuditorRegisterSuccessScreenState();
}

class _AuditorRegisterSuccessScreenState
    extends State<AuditorRegisterSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Controlador para el punto pulsante de "Pending Approval"
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // -- Design tokens --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _cyanDimColor = Color(0xFF00DAF3);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _outlineVariantColor = Color(0xFFC5C6CD);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _entryController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Blob decorativo superior-derecho
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyanColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Blob decorativo inferior-izquierdo
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryColor.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                      child: Column(
                        children: [
                          _buildIllustration(),
                          const SizedBox(height: 32),
                          _buildTypography(),
                          const SizedBox(height: 32),
                          _buildStatusCard(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  ILUSTRACIÓN — círculo gradiente con check
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
            // Halo difuso detrás del círculo
            Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyanColor.withValues(alpha: 0.15),
              ),
            ),
            // Círculo gradiente principal
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [_secondaryColor, _cyanDimColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  TIPOGRAFÍA — título y subtítulo
  // ------------------------------------------------------------------ //
  Widget _buildTypography() {
    return const Column(
      children: [
        Text(
          'Registration Submitted\nSuccessfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Your application is currently under review.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: _onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  CARD — Account Status con punto pulsante
  // ------------------------------------------------------------------ //
  Widget _buildStatusCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              // Ícono en círculo cyan
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _cyanColor.withValues(alpha: 0.18),
                ),
                child: const Icon(Icons.verified_user_outlined, color: _secondaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              // Labels
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT STATUS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariantColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pending Approval',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Punto pulsante animado
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, _) => Opacity(
                  opacity: _pulseAnim.value,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _cyanDimColor,
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

  // ------------------------------------------------------------------ //
  //  CARD — Información del proceso de revisión
  // ------------------------------------------------------------------ //
  Widget _buildInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: _onSurfaceVariantColor.withValues(alpha: 0.7), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Our institutional verification team is reviewing your Auditor credentials. This process typically takes 24–48 business hours. You will receive an email notification once your account is active.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: _onSurfaceVariantColor,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  FOOTER — CTA + branding
  // ------------------------------------------------------------------ //
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              // Navegamos directo a /home en lugar de /login para evitar el rebote
              // por el guard del router. El user ya está autenticado en Firebase;
              // /home dispatch al dashboard del rol (status pending o no, el
              // dashboard maneja ese estado en su UI).
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: _onPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Branding difuminado
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, size: 14, color: _onSurfaceVariantColor.withValues(alpha: 0.45)),
                  const SizedBox(width: 6),
                  Text(
                    'WATER LEDGER INC.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariantColor.withValues(alpha: 0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '© 2024 Secure Institutional Infrastructure',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: _onSurfaceVariantColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
