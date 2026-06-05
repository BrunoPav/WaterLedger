import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/admin/presentation/providers/admin_provider.dart';
import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_recommendation.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_status.dart';
import 'package:water_ledger/features/auditor/presentation/providers/audit_repository_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);

const _statusMeta = <String, (String, Color)>{
  'draft':      ('Borrador',      Color(0xFF9E9E9E)),
  'pending':    ('Pendiente',     Color(0xFFFF8F00)),
  'underAudit': ('En auditoría',  Color(0xFF1565C0)),
  'certified':  ('Certificado',   Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     Color(0xFF00695C)),
  'valued':     ('Valorado',      Color(0xFF6A1B9A)),
  'published':  ('Publicado',     Color(0xFF1B5E20)),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

/// Pantalla de detalle de una solicitud de crédito para el admin.
/// Implementa 4.6.3 (ver detalle) y 4.6.2 (asignar auditor).
class AdminRequestDetailScreen extends ConsumerStatefulWidget {
  const AdminRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AdminRequestDetailScreen> createState() =>
      _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState
    extends ConsumerState<AdminRequestDetailScreen> {
  UserModel? _selectedAuditor;
  bool _assigning = false;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(allCreditRequestsProvider);
    final auditorsAsync = ref.watch(activeAuditorsProvider);

    return requestAsync.when(
      data: (all) {
        final req = all.where((r) => r['id'] == widget.requestId).firstOrNull;
        if (req == null) {
          return Scaffold(
            backgroundColor: _bgColor,
            appBar: _appBar(context, 'Solicitud no encontrada'),
            body: const Center(child: Text('No se encontró la solicitud.')),
          );
        }
        final auditAsync = ref.watch(auditStreamProvider(widget.requestId));
        return Scaffold(
          backgroundColor: _bgColor,
          appBar: _appBar(context, 'Detalle de Solicitud'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusHeader(req),
                const SizedBox(height: 20),
                _buildProjectCard(req),
                const SizedBox(height: 16),
                _buildObjectivesCard(req),
                const SizedBox(height: 16),
                _buildRoadmapCard(req),
                const SizedBox(height: 16),
                _buildDocumentsCard(req),
                const SizedBox(height: 16),
                _buildAuditConclusionCard(auditAsync),
                const SizedBox(height: 24),
                auditorsAsync.when(
                  data: (auditors) => _buildAssignAuditorCard(context, req, auditors),
                  loading: () => const Center(child: CircularProgressIndicator(color: _secondaryColor)),
                  error: (e, _) => _errorBox('No se pudieron cargar los auditores: $e'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar(context, 'Cargando…'),
        body: const Center(child: CircularProgressIndicator(color: _secondaryColor)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar(context, 'Error'),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  AppBar _appBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _onSurfaceColor),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: _onSurfaceColor),
      ),
    );
  }

  // ── STATUS HEADER ────────────────────────────────────────────────────────────
  Widget _buildStatusHeader(Map<String, dynamic> req) {
    final id = req['id'] as String? ?? '—';
    final status = req['status'] as String? ?? 'draft';
    final submittedAt = req['submittedAt'];
    final createdAt = req['createdAt'];
    final (label, color) = _statusMeta[status] ?? ('Desconocido', const Color(0xFF9E9E9E));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.assignment_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
                const SizedBox(height: 2),
                Text(
                  submittedAt != null
                      ? 'Enviada el ${_fmtDate(submittedAt)}'
                      : createdAt != null
                          ? 'Creada el ${_fmtDate(createdAt)}'
                          : '—',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  // ── PROJECT INFO ─────────────────────────────────────────────────────────────
  Widget _buildProjectCard(Map<String, dynamic> req) {
    final project = req['project'] as Map<String, dynamic>?;
    if (project == null) {
      return _card(
        title: 'Proyecto',
        icon: Icons.water_drop_outlined,
        child: const Text('Sin información de proyecto cargada.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor)),
      );
    }
    return _card(
      title: 'Proyecto',
      icon: Icons.water_drop_outlined,
      child: Column(
        children: [
          _row('Nombre', project['name'] ?? '—'),
          _row('Ubicación', project['location'] ?? '—'),
          _row('Categoría', project['category'] ?? '—'),
          _row('Resumen', project['summary'] ?? '—'),
          _row('Inversión estimada', project['estimatedInvestment'] != null
              ? 'USD ${(project['estimatedInvestment'] as num).toStringAsFixed(0)}'
              : '—'),
          _row('Impacto hídrico esperado', project['expectedWaterImpact'] ?? '—'),
          _row('Créditos a emitir', req['creditAmount'] != null
              ? '${(req['creditAmount'] as num).toStringAsFixed(0)} m³'
              : '—'),
        ],
      ),
    );
  }

  // ── OBJECTIVES ───────────────────────────────────────────────────────────────
  Widget _buildObjectivesCard(Map<String, dynamic> req) {
    final project = req['project'] as Map<String, dynamic>?;
    final goal = project?['sustainabilityGoal'] as Map<String, dynamic>?;
    if (goal == null) {
      return _card(
        title: 'Objetivos de Sustentabilidad',
        icon: Icons.eco_outlined,
        child: const Text('Sin objetivos cargados.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor)),
      );
    }
    return _card(
      title: 'Objetivos de Sustentabilidad',
      icon: Icons.eco_outlined,
      child: Column(
        children: [
          _row('Objetivo principal', goal['objective'] ?? '—'),
          _row('Descripción', goal['description'] ?? '—'),
          _row('Entorno beneficiado', goal['benefittedEnvironment'] ?? '—'),
        ],
      ),
    );
  }

  // ── ROADMAP ──────────────────────────────────────────────────────────────────
  Widget _buildRoadmapCard(Map<String, dynamic> req) {
    final roadmap = req['roadmap'] as Map<String, dynamic>?;
    final phases = roadmap?['phases'] as List<dynamic>? ?? [];
    return _card(
      title: 'Roadmap',
      icon: Icons.timeline_outlined,
      child: phases.isEmpty
          ? const Text('Sin fases registradas.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor))
          : Column(
              children: phases.map((p) {
                final phase = p as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8, height: 8, margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _secondaryColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(phase['name'] ?? '—', style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceColor)),
                            Text(
                              '${phase['startDate'] ?? '—'} → ${phase['endDate'] ?? '—'}',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ── DOCUMENTS ────────────────────────────────────────────────────────────────
  Widget _buildDocumentsCard(Map<String, dynamic> req) {
    final docs = req['documents'] as List<dynamic>? ?? [];
    return _card(
      title: 'Documentos',
      icon: Icons.attach_file_outlined,
      child: docs.isEmpty
          ? const Text('Sin documentos adjuntos.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor))
          : Column(
              children: docs.map((d) {
                final doc = d as Map<String, dynamic>;
                final type = doc['type'] as String? ?? '—';
                final url = doc['storageUrl'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: _secondaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(type, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: _onSurfaceColor)),
                      ),
                      if (url.isNotEmpty)
                        const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ── ASSIGN AUDITOR (4.6.2) ───────────────────────────────────────────────────
  Widget _buildAssignAuditorCard(BuildContext context, Map<String, dynamic> req, List<UserModel> auditors) {
    final currentAuditorId = req['assignedAuditorId'] as String?;
    final currentAuditorName = req['assignedAuditorName'] as String?;
    final status = req['status'] as String? ?? 'draft';
    final canAssign = status == 'pending' || status == 'underAudit';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _secondaryColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.assignment_ind_outlined, color: _secondaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Asignar Auditor', style: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
            ],
          ),
          const SizedBox(height: 16),

          // Auditor actual
          if (currentAuditorId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _secondaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _secondaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: _secondaryColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Auditor asignado: ${currentAuditorName ?? currentAuditorId}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Reasignar a:', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor)),
            const SizedBox(height: 8),
          ],

          if (!canAssign) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'La asignación de auditor solo es posible en solicitudes con estado "Pendiente" o "En auditoría".',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)),
              ),
            ),
          ] else if (auditors.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Color(0xFFFF8F00), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay auditores activos disponibles. Aprobá un auditor primero desde la sección "Pending Approvals".',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.4)),
              ),
              child: DropdownButton<UserModel>(
                value: _selectedAuditor,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Seleccioná un auditor', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceVariantColor)),
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceColor),
                items: auditors.map((a) => DropdownMenuItem(
                  value: a,
                  child: Text(a.displayName.isNotEmpty ? a.displayName : a.email),
                )).toList(),
                onChanged: (v) => setState(() => _selectedAuditor = v),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedAuditor == null || _assigning)
                    ? null
                    : () => _confirmAssign(req),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _assigning
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.assignment_turned_in_outlined, size: 18),
                label: Text(
                  currentAuditorId != null ? 'Reasignar Auditor' : 'Asignar Auditor',
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAssign(Map<String, dynamic> req) async {
    final auditor = _selectedAuditor!;
    final name = auditor.displayName.isNotEmpty ? auditor.displayName : auditor.email;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar asignación', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: Text(
          '¿Asignar a $name como auditor de esta solicitud?\n\nEl estado cambiará a "En auditoría".',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _assigning = true);
    try {
      await ref.read(adminRepositoryProvider).assignAuditor(
        requestId: widget.requestId,
        auditorId: auditor.uid,
        auditorName: name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name asignado correctamente ✓'),
          backgroundColor: _secondaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _selectedAuditor = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar: $e')),
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────
  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _secondaryColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.75))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: _onSurfaceColor)),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF93000A), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF93000A)))),
        ],
      ),
    );
  }

  // ── Audit conclusion (read-only) ─────────────────────────────────────────────

  Widget _buildAuditConclusionCard(AsyncValue<AuditEntity?> auditAsync) {
    return auditAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (audit) {
        if (audit == null) return const SizedBox.shrink();

        final isSubmitted = audit.status == AuditStatus.submitted;
        final conclusion = audit.conclusion;

        if (!isSubmitted || conclusion == null) {
          return _card(
            title: 'Auditoría',
            icon: Icons.rate_review_outlined,
            child: Row(
              children: [
                const Icon(Icons.pending_actions_outlined, color: Color(0xFF1565C0), size: 16),
                const SizedBox(width: 8),
                Text(
                  'En curso — ${audit.observations.length} observación(es) registrada(s).',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF1565C0)),
                ),
              ],
            ),
          );
        }

        final recColor = switch (conclusion.recommendation) {
          AuditRecommendation.approve => const Color(0xFF2E7D32),
          AuditRecommendation.reject => const Color(0xFFC62828),
          AuditRecommendation.needsMoreInfo => const Color(0xFFFF8F00),
        };
        final recIcon = switch (conclusion.recommendation) {
          AuditRecommendation.approve => Icons.check_circle_outline,
          AuditRecommendation.reject => Icons.cancel_outlined,
          AuditRecommendation.needsMoreInfo => Icons.help_outline,
        };

        return _card(
          title: 'Conclusión de Auditoría',
          icon: Icons.gavel_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(recIcon, color: recColor, size: 18),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: recColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: recColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      conclusion.recommendation.label,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: recColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _fmtDate(conclusion.submittedAt),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conclusion.notes,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceColor, height: 1.5),
              ),
              if (audit.observations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${audit.observations.length} observación(es) registrada(s).',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.75)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _fmtDate(dynamic value) {
    if (value is DateTime) return DateFormat('d MMM yyyy', 'es').format(value);
    return '—';
  }
}
