import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
import 'package:water_ledger/core/domain/repositories/admin_repository.dart';
import 'package:water_ledger/core/presentation/providers/admin_provider.dart';

/// Bottom sheet con notificaciones para el admin.
///
/// Mientras no exista una colección dedicada `notifications`, las notificaciones
/// se derivan en vivo de:
///   - `pendingUsersProvider` → cada solicitud pendiente es un item accionable
///   - `recentAdminDecisionsProvider` → las últimas decisiones del admin
///
/// Esto evita hardcodear data fake y mantiene el modal sincronizado con la
/// realidad del sistema. Cuando exista módulo de notificaciones propio,
/// reemplazar la lectura por su provider.
Future<void> showAdminNotificationsModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  static const _bgColor = Color(0xFFFFFFFF);
  static const _primaryColor = Color(0xFF000000);
  static const _secondaryColor = Color(0xFF006875);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _secondaryFixedColor = Color(0xFF9CF0FF);
  static const _onSecondaryFixedColor = Color(0xFF001F24);
  static const _approvalGreen = Color(0xFF469446);
  static const _errorColor = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingUsersProvider);
    final decisionsAsync = ref.watch(recentAdminDecisionsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPendingSection(context, pendingAsync),
                      const SizedBox(height: 24),
                      _buildDecisionsSection(decisionsAsync),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ //
  //  HEADER
  // ------------------------------------------------------------------ //
  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: _outlineVariantColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Notificaciones',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: _onSurfaceVariantColor),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  PENDING SECTION — cada pending = 1 notificación accionable
  // ------------------------------------------------------------------ //
  Widget _buildPendingSection(
    BuildContext context,
    AsyncValue<List<dynamic>> pendingAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SOLICITUDES PENDIENTES'),
        const SizedBox(height: 10),
        pendingAsync.when(
          loading: () => const _LoadingTile(),
          error: (_, _) => _emptyTile(
            icon: Icons.error_outline,
            text: 'No se pudieron cargar las solicitudes.',
          ),
          data: (users) {
            if (users.isEmpty) {
              return _emptyTile(
                icon: Icons.inbox_outlined,
                text: 'Sin solicitudes pendientes en este momento.',
              );
            }
            return Column(
              children: [
                for (final u in users)
                  _PendingNotificationTile(
                    name: u.displayName.isEmpty ? u.email : u.displayName,
                    role: _roleLabel(u.role),
                    createdAt: u.createdAt,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/admin-pending-detail/${u.uid}');
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  DECISIONS SECTION — últimas N decisiones del admin
  // ------------------------------------------------------------------ //
  Widget _buildDecisionsSection(AsyncValue<List<AdminDecisionRecord>> async) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ACTIVIDAD RECIENTE'),
        const SizedBox(height: 10),
        async.when(
          loading: () => const _LoadingTile(),
          error: (_, _) => _emptyTile(
            icon: Icons.error_outline,
            text: 'No se pudo cargar la actividad.',
          ),
          data: (records) {
            if (records.isEmpty) {
              return _emptyTile(
                icon: Icons.history_toggle_off_outlined,
                text: 'Las decisiones recientes van a aparecer acá.',
              );
            }
            return Column(
              children: [
                for (final r in records) _DecisionNotificationTile(record: r),
              ],
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _onSurfaceVariantColor.withValues(alpha: 0.75),
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _emptyTile({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.auditor:    return 'Auditor';
      case UserRole.certifier:  return 'Certificadora';
      case UserRole.insurer:    return 'Aseguradora';
      case UserRole.issuer:     return 'Empresa emisora';
      case UserRole.company:    return 'Empresa';
      case UserRole.retail:     return 'Retail';
      case UserRole.admin:      return 'Admin';
    }
  }
}

// ------------------------------------------------------------------ //
//  TILES
// ------------------------------------------------------------------ //

class _PendingNotificationTile extends StatelessWidget {
  final String name;
  final String role;
  final DateTime createdAt;
  final VoidCallback onTap;

  const _PendingNotificationTile({
    required this.name,
    required this.role,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5C6CD).withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: _NotificationsSheet._secondaryFixedColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_outlined,
                  color: _NotificationsSheet._onSecondaryFixedColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva solicitud: $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _NotificationsSheet._onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$role · ${_timeAgo(createdAt)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _NotificationsSheet._onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _NotificationsSheet._onSurfaceVariantColor.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionNotificationTile extends StatelessWidget {
  final AdminDecisionRecord record;

  const _DecisionNotificationTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isApproved = record.decision == UserStatus.active;
    final color = isApproved
        ? _NotificationsSheet._approvalGreen
        : _NotificationsSheet._errorColor;
    final icon = isApproved ? Icons.check_circle_outline : Icons.cancel_outlined;
    final action = isApproved ? 'Aprobado' : 'Rechazado';
    final name = record.displayName.trim().isEmpty
        ? record.email
        : record.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5C6CD).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$action: $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _NotificationsSheet._onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(record.decidedAt),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _NotificationsSheet._onSurfaceVariantColor,
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

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _NotificationsSheet._secondaryColor,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ //
//  Formatter relativo (top-level para que ambos tiles lo puedan usar)
// ------------------------------------------------------------------ //
String _timeAgo(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 60) return 'hace instantes';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays == 1) return 'ayer';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  return DateFormat('d MMM', 'es').format(when);
}
