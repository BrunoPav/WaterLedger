import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/presentation/providers/admin_provider.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  // -- Design tokens del template (admin-dashboard-Template/DESIGN.md) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceLowestColor = Color(0xFFFFFFFF);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _secondaryFixedColor = Color(0xFF9CF0FF);
  static const _onSecondaryFixedColor = Color(0xFF001F24);
  static const _primaryContainerColor = Color(0xFF0D1C32);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(context, ref),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderText(),
                        const SizedBox(height: 24),
                        _buildKpiGrid(ref),
                        const SizedBox(height: 28),
                        _buildPendingApprovalsSection(context, ref),
                        const SizedBox(height: 28),
                        _buildProjectMonitoringSection(),
                        const SizedBox(height: 28),
                        _buildRecentActivitySection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  TOP APP BAR — avatar con iniciales del admin (sin imagen hardcodeada)
  // ------------------------------------------------------------------ //
  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              _buildAdminAvatar(session.value),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Water Ledger',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: _primaryColor, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminAvatar(UserModel? user) {
    final initial = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName.trim()[0].toUpperCase()
        : (user?.email.isNotEmpty ?? false)
            ? user!.email.trim()[0].toUpperCase()
            : 'A';
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryContainerColor,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HEADER TEXT
  // ------------------------------------------------------------------ //
  Widget _buildHeaderText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrator Dashboard',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _onSurfaceColor,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage platform operations, approvals, audits, certifications, and project valuation.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: _onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  KPI GRID — 4 cards. User Approvals real, otras desde colecciones reales (hoy 0).
  // ------------------------------------------------------------------ //
  Widget _buildKpiGrid(WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _kpiCard(
                icon: Icons.person_add_alt_outlined,
                label: 'User Approvals',
                asyncValue: ref.watch(pendingApprovalsCountProvider),
              ),
              const SizedBox(height: 16),
              _kpiCard(
                icon: Icons.verified_outlined,
                label: 'Certifications',
                asyncValue: ref.watch(collectionCountProvider('certifications')),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _kpiCard(
                icon: Icons.account_tree_outlined,
                label: 'Active Projects',
                asyncValue: ref.watch(collectionCountProvider('projects')),
              ),
              const SizedBox(height: 16),
              _kpiCard(
                icon: Icons.analytics_outlined,
                label: 'Valuations',
                asyncValue: ref.watch(collectionCountProvider('valuations')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String label,
    required AsyncValue<int> asyncValue,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _secondaryColor, size: 22),
              const SizedBox(height: 14),
              asyncValue.when(
                data: (count) => Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                    height: 1,
                  ),
                ),
                loading: () => const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _secondaryColor),
                ),
                error: (_, _) => const Text(
                  '—',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceVariantColor,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariantColor.withValues(alpha: 0.85),
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  PENDING APPROVALS — lista en vivo de Firestore
  // ------------------------------------------------------------------ //
  Widget _buildPendingApprovalsSection(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUsersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title: 'Pending Approvals', trailing: 'View all'),
        const SizedBox(height: 14),
        pending.when(
          data: (users) {
            if (users.isEmpty) {
              return _emptyState(
                icon: Icons.inbox_outlined,
                title: 'Sin solicitudes pendientes',
                subtitle: 'Cuando un auditor, certificadora o aseguradora se registre, aparecerá acá para su revisión.',
              );
            }
            return Column(
              children: users
                  .map((u) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _pendingCard(context, u),
                      ))
                  .toList(),
            );
          },
          loading: () => _loadingBox(),
          error: (e, _) => _errorBox('No se pudieron cargar las solicitudes pendientes: $e'),
        ),
      ],
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
            color: Colors.white.withValues(alpha: 0.7),
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

  // ------------------------------------------------------------------ //
  //  PROJECT MONITORING — sin colección backing todavía, muestra empty state
  // ------------------------------------------------------------------ //
  Widget _buildProjectMonitoringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title: 'Project Monitoring'),
        const SizedBox(height: 14),
        _emptyState(
          icon: Icons.account_tree_outlined,
          title: 'Sin proyectos en seguimiento',
          subtitle: 'Cuando se carguen proyectos al sistema, vas a poder monitorearlos desde acá.',
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  RECENT ACTIVITY — sin log todavía
  // ------------------------------------------------------------------ //
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title: 'Recent Activity'),
        const SizedBox(height: 14),
        _emptyState(
          icon: Icons.history,
          title: 'Sin actividad reciente',
          subtitle: 'Las aprobaciones, certificaciones y eventos del sistema se van a registrar acá.',
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS DE PRESENTACIÓN
  // ------------------------------------------------------------------ //
  Widget _buildSectionTitle({required String title, String? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _onSurfaceColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _secondaryColor,
            ),
          ),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cyanColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: _secondaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _onSurfaceVariantColor.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2, color: _secondaryColor),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF93000A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF93000A),
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
      case UserRole.auditor:
        return 'Auditor';
      case UserRole.certifier:
        return 'Certificadora';
      case UserRole.insurer:
        return 'Aseguradora';
      case UserRole.company:
        return 'Empresa';
      case UserRole.retail:
        return 'Retail';
      case UserRole.admin:
        return 'Admin';
    }
  }

  // ------------------------------------------------------------------ //
  //  BOTTOM NAV — placeholders mientras las otras pantallas no existen
  // ------------------------------------------------------------------ //
  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.2)),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home_rounded, label: 'Home', active: true),
              _navItem(icon: Icons.pending_actions_outlined, label: 'Requests'),
              _navItem(icon: Icons.water_drop_outlined, label: 'Credits'),
              _navItem(icon: Icons.storefront_outlined, label: 'Market'),
              _navItem(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, bool active = false}) {
    final color = active ? _secondaryColor : _onSurfaceVariantColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: active
          ? BoxDecoration(
              color: _cyanColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
