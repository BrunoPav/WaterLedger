import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/presentation/providers/admin_provider.dart';

/// Pantalla de detalle de una solicitud de aprobación pendiente.
///
/// Lee el documento completo del usuario en Firestore (incluye `companyData`,
/// `representativeData` y `<role>RoleData`) y permite aprobar o rechazar la
/// solicitud. La acción actualiza `status` en Firestore y vuelve al dashboard;
/// la lista de pendientes se refresca sola porque viene de un Stream.
class PendingRequestDetailScreen extends ConsumerStatefulWidget {
  final String uid;
  const PendingRequestDetailScreen({super.key, required this.uid});

  @override
  ConsumerState<PendingRequestDetailScreen> createState() =>
      _PendingRequestDetailScreenState();
}

class _PendingRequestDetailScreenState
    extends ConsumerState<PendingRequestDetailScreen> {
  bool _isProcessing = false;

  // -- Design tokens --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _surfaceLowestColor = Color(0xFFFFFFFF);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _secondaryFixedColor = Color(0xFF9CF0FF);
  static const _onSecondaryFixedColor = Color(0xFF001F24);
  static const _approvalGreen = Color(0xFF469446);
  static const _errorColor = Color(0xFFBA1A1A);

  Future<void> _confirmAndApprove() async {
    final ok = await _showConfirmDialog(
      title: '¿Aprobar la solicitud?',
      body: 'El usuario va a pasar a estado activo y podrá operar en la plataforma.',
      confirmLabel: 'Aprobar',
      confirmColor: _approvalGreen,
    );
    if (ok != true) return;
    setState(() => _isProcessing = true);
    try {
      await ref.read(adminRepositoryProvider).approveUser(widget.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aprobada')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aprobar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _confirmAndReject() async {
    final ok = await _showConfirmDialog(
      title: '¿Rechazar la solicitud?',
      body: 'El usuario quedará marcado como rechazado y no podrá operar en la plataforma.',
      confirmLabel: 'Rechazar',
      confirmColor: _errorColor,
    );
    if (ok != true) return;
    setState(() => _isProcessing = true);
    try {
      await ref.read(adminRepositoryProvider).rejectUser(widget.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceLowestColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _onSurfaceColor,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: _onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariantColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(userFullDataProvider(widget.uid));
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: asyncData.when(
                data: (data) => _buildContent(context, data),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: _secondaryColor),
                ),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
            asyncData.maybeWhen(
              data: (_) => _buildBottomActions(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HEADER
  // ------------------------------------------------------------------ //
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
          bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor),
          ),
          const Expanded(
            child: Text(
              'Solicitud pendiente',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  CONTENIDO PRINCIPAL — secciones armadas desde el doc de Firestore
  // ------------------------------------------------------------------ //
  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final role = UserRole.fromString(data['role'] as String? ?? 'Retail');
    final companyData = (data['companyData'] as Map?)?.cast<String, dynamic>();
    final representativeData =
        (data['representativeData'] as Map?)?.cast<String, dynamic>();
    final roleData = _roleSpecificData(data, role);
    final roleDataLabel = _roleSpecificLabel(role);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBlock(data, role),
          const SizedBox(height: 18),
          _buildSection(
            title: 'Información de la cuenta',
            icon: Icons.account_circle_outlined,
            children: [
              _kv('Email de la cuenta', data['email']?.toString()),
              _kv('Nombre visible', data['displayName']?.toString()),
              _kv('Rol solicitado', _roleLabel(role)),
              _kv('Fecha de registro', _formatTimestamp(data['createdAt'])),
              if (data['auditorType'] != null)
                _kv('Tipo de auditor', data['auditorType']?.toString()),
            ],
          ),
          if (companyData != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Datos de la empresa',
              icon: Icons.corporate_fare,
              children: _mapToFields(companyData),
            ),
          ],
          if (representativeData != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Representante legal',
              icon: Icons.person_outline,
              children: _mapToFields(representativeData),
            ),
          ],
          if (roleData != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: roleDataLabel,
              icon: Icons.workspace_premium_outlined,
              children: _mapToFields(roleData),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroBlock(Map<String, dynamic> data, UserRole role) {
    final name = (data['displayName'] as String?)?.trim();
    final shownName = (name == null || name.isEmpty) ? data['email']?.toString() ?? '—' : name;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cyanColor.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.business_outlined, color: _secondaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shownName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                    const SizedBox(width: 8),
                    Text(
                      _roleLabel(role),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  SECCIONES Y FIELDS
  // ------------------------------------------------------------------ //
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _secondaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Convierte un map arbitrario en una lista de filas key-value, ignorando
  /// los keys que están vacíos. Acepta keys en cualquier casing — los humaniza
  /// para mostrarlos.
  List<Widget> _mapToFields(Map<String, dynamic> map) {
    final widgets = <Widget>[];
    for (final entry in map.entries) {
      final label = _humanizeKey(entry.key);
      final value = _formatValue(entry.value);
      if (value == null || value.isEmpty) continue;
      widgets.add(_kv(label, value));
    }
    if (widgets.isEmpty) {
      widgets.add(Text(
        'Sin datos cargados.',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: _onSurfaceVariantColor.withValues(alpha: 0.7),
        ),
      ));
    }
    return widgets;
  }

  Widget _kv(String label, String? value) {
    final shown = (value == null || value.isEmpty) ? '—' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            shown,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _onSurfaceColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  Map<String, dynamic>? _roleSpecificData(Map<String, dynamic> data, UserRole role) {
    switch (role) {
      case UserRole.auditor:
        return (data['auditorRoleData'] as Map?)?.cast<String, dynamic>();
      case UserRole.certifier:
        return (data['certifierRoleData'] as Map?)?.cast<String, dynamic>();
      case UserRole.insurer:
        return (data['insurerRoleData'] as Map?)?.cast<String, dynamic>();
      case UserRole.retail:
      case UserRole.company:
      case UserRole.admin:
        return null;
    }
  }

  String _roleSpecificLabel(UserRole role) {
    switch (role) {
      case UserRole.auditor:
        return 'Habilitación profesional';
      case UserRole.certifier:
        return 'Acreditación de certificación';
      case UserRole.insurer:
        return 'Autorización y cobertura';
      default:
        return 'Datos del rol';
    }
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

  /// Convierte `fantasyName` → `Fantasy name`, `nombreFantasia` → `Nombre fantasia`,
  /// `ID_number` → `Id number`. Funciona con camelCase y snake_case.
  String _humanizeKey(String key) {
    final spaced = key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase();
    if (spaced.isEmpty) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  String? _formatValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim();
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is Timestamp) return _formatTimestamp(value);
    if (value is List) return value.map((e) => e.toString()).join(', ');
    if (value is Map) {
      return value.entries
          .map((e) => '${_humanizeKey(e.key.toString())}: ${_formatValue(e.value) ?? '—'}')
          .join(' · ');
    }
    return value.toString();
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('d MMM yyyy · HH:mm', 'es').format(value.toDate());
    }
    if (value is DateTime) {
      return DateFormat('d MMM yyyy · HH:mm', 'es').format(value);
    }
    return value?.toString() ?? '—';
  }

  // ------------------------------------------------------------------ //
  //  ERROR STATE
  // ------------------------------------------------------------------ //
  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _errorColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar la solicitud',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _onSurfaceColor.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTTOM ACTIONS — Approve + Reject
  // ------------------------------------------------------------------ //
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: _surfaceContainerLowColor,
        border: Border(
          top: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : _confirmAndReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: _errorColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: _errorColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Rechazar',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _confirmAndApprove,
              icon: _isProcessing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Aprobar',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
