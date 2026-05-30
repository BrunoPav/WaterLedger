import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Banner visible que se muestra en los dashboards de los roles B2B
/// (auditor, certificador, asegurador) mientras la cuenta tiene status `pending`.
///
/// Explica al usuario que su solicitud está siendo revisada por un administrador
/// y que recibirá una notificación cuando la cuenta sea aprobada. Usa tonos
/// ámbar/amarillo para comunicar "en proceso, esperá" sin alarmar.
class PendingApprovalBanner extends StatelessWidget {
  const PendingApprovalBanner({super.key});

  // Paleta ámbar para "in review" — contrasta con el cyan del resto del dashboard
  // y comunica "atención, está pendiente" sin ser tan agresivo como un error rojo.
  static const _bg = Color(0xFFFFF4E5);
  static const _border = Color(0xFFFFB547);
  static const _accent = Color(0xFFB85C00);
  static const _accentDark = Color(0xFF8A4500);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono en círculo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _border.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: _accentDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu cuenta está en revisión',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _accentDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Un administrador está revisando tu solicitud. Vas a recibir '
                  'un email cuando tu cuenta sea aprobada. Mientras tanto, '
                  'algunas funciones operativas pueden estar deshabilitadas.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: DashboardTokens.onSurfaceColor.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
