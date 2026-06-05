import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() =>
      _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState
    extends State<RegisterSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
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
      backgroundColor: RegisterFormTokens.bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RegisterFormTokens.cyanColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RegisterFormTokens.primaryColor.withValues(alpha: 0.03),
              ),
            ),
          ),
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

  Widget _buildIllustration() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 192,
        height: 192,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RegisterFormTokens.cyanColor.withValues(alpha: 0.15),
              ),
            ),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    RegisterFormTokens.secondaryColor,
                    RegisterFormTokens.cyanDim,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: RegisterFormTokens.secondaryColor.withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypography() {
    return const Column(
      children: [
        Text(
          'Registro Enviado\nExitosamente',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: RegisterFormTokens.primaryColor,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Tu solicitud está siendo revisada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: RegisterFormTokens.onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

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
            border: Border.all(
              color: RegisterFormTokens.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RegisterFormTokens.cyanColor.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: RegisterFormTokens.secondaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO DE CUENTA',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: RegisterFormTokens.onSurfaceVariantColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pendiente de Aprobación',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: RegisterFormTokens.onSurfaceColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, _) => Opacity(
                  opacity: _pulseAnim.value,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: RegisterFormTokens.cyanDim,
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
            border: Border.all(
              color: RegisterFormTokens.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nuestro equipo de verificación institucional está revisando tus credenciales. '
                  'Este proceso generalmente toma entre 24 y 48 horas hábiles. Recibirás '
                  'una notificación por email una vez que tu cuenta esté activa.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: RegisterFormTokens.onSurfaceVariantColor,
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
              // por el guard del router (el user ya está autenticado en Firebase;
              // /home dispatch al dashboard del rol que le corresponde).
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RegisterFormTokens.primaryColor,
                foregroundColor: RegisterFormTokens.onPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 14,
                    color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WATER LEDGER INC.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '© 2024 Infraestructura Institucional Segura',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
