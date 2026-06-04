import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// TopAppBar glassmorphism reusable para todos los dashboards.
/// Permite variar el lado izquierdo (avatar+brand o título) y los íconos del lado derecho.
class DashboardTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final List<Widget> actions;

  const DashboardTopBar({
    super.key,
    required this.leading,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: DashboardTokens.bgColor.withValues(alpha: 0.75),
            border: Border(
              bottom: BorderSide(
                color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: leading),
                    ...actions,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Variante "avatar + Water Ledger" usada en Company/Retail.
class TopBarBranded extends StatelessWidget {
  final String brandName;
  final String? avatarInitial;

  const TopBarBranded({
    super.key,
    this.brandName = 'Water Ledger',
    this.avatarInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DashboardTokens.primaryColor.withValues(alpha: 0.08),
            border: Border.all(
              color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              avatarInitial ?? '·',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          brandName,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: DashboardTokens.primaryColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Variante "título plano" — usada en Auditor / Certifier ("Auditor Dashboard").
class TopBarTitled extends StatelessWidget {
  final String title;

  const TopBarTitled({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: DashboardTokens.primaryColor,
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Botón de ícono circular para usar en `actions`.
class TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasDot;

  const TopBarIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: DashboardTokens.onSurfaceVariantColor, size: 22),
          ),
          if (hasDot)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DashboardTokens.errorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
