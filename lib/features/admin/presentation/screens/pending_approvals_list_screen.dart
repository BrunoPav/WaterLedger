import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/admin/presentation/providers/admin_provider.dart';

/// Pantalla completa con todas las solicitudes pendientes — destino del
/// "View all" del admin dashboard.
/// Usa el mismo `pendingUsersProvider` que el dashboard, así la lista se
/// actualiza en vivo cuando una solicitud cambia de status.
class PendingApprovalsListScreen extends ConsumerWidget {
  const PendingApprovalsListScreen({super.key});

  // -- Design tokens (alineados con el dashboard) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _secondaryColor = Color(0xFF006875);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _secondaryFixedColor = Color(0xFF9CF0FF);
  static const _onSecondaryFixedColor = Color(0xFF001F24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUsersProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, pending),
            Expanded(
              child: pending.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: _secondaryColor),
                ),
                error: (e, _) => _buildErrorState(),
                data: (users) {
                  if (users.isEmpty) return _buildEmptyState();
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Stream-backed: pegar refresh no recarga nada nuevo, pero
                      // damos feedback visual de que se intentó.
                      await Future.delayed(const Duration(milliseconds: 200));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _pendingCard(context, users[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<UserModel>> pending) {
    final count = pending.maybeWhen(data: (u) => u.length, orElse: () => 0);
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
          bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending approvals',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0
                        ? 'Sin solicitudes pendientes'
                        : count == 1
                            ? '1 solicitud esperando revisión'
                            : '$count solicitudes esperando revisión',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: _onSurfaceVariantColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(BuildContext context, UserModel user) {
    final roleLabel = _roleLabel(user.role);
    final dateLabel = DateFormat('d MMM yyyy', 'es').format(user.createdAt);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName.isEmpty ? user.email : user.displayName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _onSurfaceColor,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$roleLabel • $dateLabel',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: _onSurfaceVariantColor.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _secondaryFixedColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _onSecondaryFixedColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin-pending-detail/${user.uid}'),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text(
                    'Ver solicitud',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _secondaryFixedColor.withValues(alpha: 0.4),
              ),
              child: const Icon(Icons.inbox_outlined, size: 30, color: _secondaryColor),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sin solicitudes pendientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cuando un auditor, certificadora o aseguradora se registre, vas a poder revisarlo desde acá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Color(0xFFBA1A1A)),
            const SizedBox(height: 10),
            const Text(
              'No se pudieron cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reintentá en unos segundos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
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
