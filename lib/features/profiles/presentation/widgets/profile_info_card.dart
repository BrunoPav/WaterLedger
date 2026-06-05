import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Card "Basic Information" compartida por todos los perfiles.
/// Muestra los datos reales del UserModel: email, displayName, status, fecha de registro.
/// El phone se muestra como placeholder porque hoy no está en el UserModel raíz
/// (vive dentro de `representativeData`/`companyData` en Firestore, sin getter directo).
class ProfileInfoCard extends StatelessWidget {
  final UserModel user;
  /// Label del status que se muestra en el chip de estado de cuenta.
  /// Por defecto deriva del UserStatus, pero algunos roles lo override (ej Admin → "Superuser").
  final String? statusLabelOverride;

  const ProfileInfoCard({
    super.key,
    required this.user,
    this.statusLabelOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: user.email,
          ),
          const Divider(height: 22, color: DashboardTokens.outlineVariantColor),
          _row(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            // TODO: cuando exista getter para teléfono en UserModel (hoy vive
            // dentro de representativeData en Firestore), reemplazar este "—".
            value: '—',
          ),
          const Divider(height: 22, color: DashboardTokens.outlineVariantColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _miniColumn(
                  label: 'Fecha de registro',
                  value: _formatRegistrationDate(user.createdAt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniColumn(
                  label: 'Estado de cuenta',
                  valueWidget: _StatusValue(
                    status: user.status,
                    labelOverride: statusLabelOverride,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DashboardTokens.surfaceContainerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: DashboardTokens.onSurfaceVariantColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.onSurfaceVariantColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniColumn({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: DashboardTokens.onSurfaceVariantColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        if (valueWidget != null)
          valueWidget
        else
          Text(
            value ?? '—',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
      ],
    );
  }

  String _formatRegistrationDate(DateTime d) {
    return DateFormat('MMM y').format(d);
  }
}

class _StatusValue extends StatelessWidget {
  final UserStatus status;
  final String? labelOverride;

  const _StatusValue({required this.status, this.labelOverride});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      UserStatus.active => DashboardTokens.onTertiaryContainerColor,
      UserStatus.pending => DashboardTokens.secondaryColor,
      UserStatus.rejected => DashboardTokens.errorColor,
    };
    final label = labelOverride ?? switch (status) {
      UserStatus.active => 'Activo',
      UserStatus.pending => 'Pendiente',
      UserStatus.rejected => 'Rechazado',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
