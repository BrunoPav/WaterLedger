import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  // -- Design tokens --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _onPrimaryContainerColor = Color(0xFF76849F);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _surfaceContainerHighestColor = Color(0xFFE0E3E5);

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward().whenComplete(() {
        if (mounted) context.go('/login');
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Gradiente de fondo (surface → cyan sutil en esquina superior derecha)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    _bgColor,
                    _bgColor.withValues(alpha: 0.9),
                    const Color(0xFF9CF0FF).withValues(alpha: 0.09),
                  ],
                ),
              ),
            ),
          ),
          // Contenido central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 36),
                // Título
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
                  'Institutional Water Credit Excellence',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariantColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 36),
                // Barra de progreso animada
                _buildProgressBar(),
                const SizedBox(height: 12),
                const Text(
                  'SYNCHRONIZING LEDGER...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _onPrimaryContainerColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Footer: badge glass inferior
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  LOGO: anillo glass + círculo gradiente + water drop + orbit badge
  // ------------------------------------------------------------------ //
  Widget _buildLogo() {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Anillo exterior glass
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: _outlineVariantColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Círculo interior con gradiente teal → cyan
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_secondaryColor, _cyanColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          // Orbit badge: pequeño círculo glass en esquina superior derecha
          Positioned(
            top: -4,
            right: -4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _cyanColor.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: _secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BARRA DE PROGRESO: gradiente + glow animados en 2 segundos
  // ------------------------------------------------------------------ //
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        return Container(
          width: 192,
          height: 6,
          decoration: BoxDecoration(
            color: _surfaceContainerHighestColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressController.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [_secondaryColor, _cyanColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _cyanColor.withValues(alpha: 0.45),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ //
  //  FOOTER: badge glass con "Carbon Neutral Infrastructure"
  // ------------------------------------------------------------------ //
  Widget _buildFooter() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _outlineVariantColor.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: _secondaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Institutional Water Credit Excellence',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceVariantColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
