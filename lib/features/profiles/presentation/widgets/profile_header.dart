import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Header reusable de las pantallas de perfil.
/// Muestra avatar (con inicial), nombre, badges (chips de rol/status/region)
/// y los CTAs "Edit Profile" + "Logout".
class ProfileHeader extends ConsumerWidget {
  final String name;
  final List<ProfileBadge> badges;

  const ProfileHeader({
    super.key,
    required this.name,
    this.badges = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = name.trim().isEmpty ? '·' : name.trim()[0].toUpperCase();
    return Column(
      children: [
        // Avatar grande con la inicial
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DashboardTokens.cyanColor.withValues(alpha: 0.12),
            border: Border.all(
              color: DashboardTokens.cyanColor.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: DashboardTokens.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Nombre
        Text(
          name.isEmpty ? 'Sin nombre' : name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: DashboardTokens.primaryColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        // Badges (Rol, Región, Status, etc.)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: badges.map((b) => _BadgeChip(badge: b)).toList(),
        ),
        const SizedBox(height: 18),
        // CTAs: Edit Profile (placeholder) + Logout (real)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EditProfileButton(),
            const SizedBox(width: 10),
            _LogoutButton(),
          ],
        ),
      ],
    );
  }
}

/// Modelo simple para un chip del header. Cada perfil define sus propios badges.
class ProfileBadge {
  final String label;
  final ProfileBadgeStyle style;
  final IconData? icon;

  const ProfileBadge({
    required this.label,
    this.style = ProfileBadgeStyle.neutral,
    this.icon,
  });
}

enum ProfileBadgeStyle {
  /// Negro con texto blanco — para el rol principal
  primary,
  /// Verde mint — para "Verified", "Active"
  positive,
  /// Cyan claro — para "Authorized", "Approved"
  info,
  /// Gris suave — para region, default
  neutral,
}

class _BadgeChip extends StatelessWidget {
  final ProfileBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(badge.style);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.icon != null) ...[
            Icon(badge.icon, size: 13, color: colors.fg),
            const SizedBox(width: 5),
          ],
          Text(
            badge.label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  _ChipColors _colorsFor(ProfileBadgeStyle style) {
    switch (style) {
      case ProfileBadgeStyle.primary:
        return const _ChipColors(
          bg: DashboardTokens.primaryColor,
          fg: Colors.white,
        );
      case ProfileBadgeStyle.positive:
        return const _ChipColors(
          bg: DashboardTokens.tertiaryFixedColor,
          fg: DashboardTokens.onTertiaryFixedColor,
        );
      case ProfileBadgeStyle.info:
        return _ChipColors(
          bg: DashboardTokens.cyanColor.withValues(alpha: 0.18),
          fg: DashboardTokens.secondaryColor,
        );
      case ProfileBadgeStyle.neutral:
        return _ChipColors(
          bg: DashboardTokens.surfaceContainerColor,
          fg: DashboardTokens.onSurfaceVariantColor,
        );
    }
  }
}

class _ChipColors {
  final Color bg;
  final Color fg;
  const _ChipColors({required this.bg, required this.fg});
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.push('/profile/edit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: DashboardTokens.primaryColor,
        foregroundColor: DashboardTokens.onPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: const Text(
        'Edit Profile',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _confirmAndLogout(context, ref),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        side: BorderSide(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.7),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(
        Icons.logout,
        size: 16,
        color: DashboardTokens.onSurfaceColor,
      ),
      label: const Text(
        'Logout',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DashboardTokens.onSurfaceColor,
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Querés cerrar la sesión actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardTokens.primaryColor,
              foregroundColor: DashboardTokens.onPrimaryColor,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Logout REAL contra Firebase — el sessionProvider va a emitir null y
      // el router (via redirect guard) va a patear a /login automáticamente.
      // De todos modos hacemos un context.go('/login') por las dudas.
      await ref.read(authRepositoryProvider).logout();
      if (!context.mounted) return;
      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
