import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_recommendation.dart';
import 'package:water_ledger/features/auditor/presentation/providers/audit_repository_provider.dart';
import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';
import 'package:water_ledger/features/certifier/domain/enums/certification_status.dart';
import 'package:water_ledger/features/certifier/presentation/providers/certification_repository_provider.dart';
import 'package:water_ledger/features/certifier/presentation/providers/certifier_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);
const _errorColor            = Color(0xFFC62828);
const _successColor          = Color(0xFF2E7D32);
const _warningColor          = Color(0xFFFF8F00);

const _statusMeta = <String, (String, Color)>{
  'draft':      ('Borrador',      Color(0xFF9E9E9E)),
  'pending':    ('Pendiente',     Color(0xFFFF8F00)),
  'underAudit': ('En auditoría',  Color(0xFF1565C0)),
  'certified':  ('Aprobado Auditoría', Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     Color(0xFF00695C)),
  'valued':     ('Valorado',      Color(0xFF6A1B9A)),
  'published':  ('Publicado',     Color(0xFF1B5E20)),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

class CertifierRequestDetailScreen extends ConsumerStatefulWidget {
  const CertifierRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<CertifierRequestDetailScreen> createState() =>
      _CertifierRequestDetailScreenState();
}

class _CertifierRequestDetailScreenState
    extends ConsumerState<CertifierRequestDetailScreen> {
  final _notesCtrl = TextEditingController();
  bool _issuing = false;
  bool _rejecting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _issueCertificate() async {
    final notes = _notesCtrl.text.trim();
    if (notes.isEmpty) {
      _showError('Las notas son obligatorias antes de emitir el certificado.');
      return;
    }
    final confirmed = await _showConfirmDialog(
      action: 'Emitir Certificado',
      message: '¿Confirmás la emisión del certificado? La solicitud pasará al estado "Asegurado".',
      confirmLabel: 'Emitir',
      confirmColor: _successColor,
    );
    if (!confirmed || !mounted) return;

    final user = ref.read(sessionProvider).value;
    if (user == null) return;

    setState(() => _issuing = true);
    try {
      await ref.read(issueCertificateUseCaseProvider).call(
            requestId: widget.requestId,
            certifierId: user.uid,
            notes: notes,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificado emitido correctamente ✓'),
          backgroundColor: _successColor,
          duration: Duration(seconds: 3),
        ),
      );
      ref.invalidate(certifierRequestDetailProvider(widget.requestId));
    } catch (e) {
      if (!mounted) return;
      _showError('Error al emitir certificado: $e');
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  Future<void> _rejectCertification() async {
    final notes = _notesCtrl.text.trim();
    if (notes.isEmpty) {
      _showError('Las notas son obligatorias antes de rechazar.');
      return;
    }
    final confirmed = await _showConfirmDialog(
      action: 'Rechazar Certificación',
      message: '¿Confirmás el rechazo de la certificación? Esta acción no se puede deshacer.',
      confirmLabel: 'Rechazar',
      confirmColor: _errorColor,
    );
    if (!confirmed || !mounted) return;

    final user = ref.read(sessionProvider).value;
    if (user == null) return;

    setState(() => _rejecting = true);
    try {
      await ref.read(rejectCertificationUseCaseProvider).call(
            requestId: widget.requestId,
            certifierId: user.uid,
            notes: notes,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificación rechazada.'),
          backgroundColor: _errorColor,
          duration: Duration(seconds: 3),
        ),
      );
      ref.invalidate(certifierRequestDetailProvider(widget.requestId));
    } catch (e) {
      if (!mounted) return;
      _showError('Error al rechazar certificación: $e');
    } finally {
      if (mounted) setState(() => _rejecting = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String action,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              action,
              style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
            ),
            content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _errorColor),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(certifierRequestDetailProvider(widget.requestId));
    final auditAsync = ref.watch(auditStreamProvider(widget.requestId));
    final certificationAsync = ref.watch(certificationStreamProvider(widget.requestId));

    return requestAsync.when(
      loading: () => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar('Cargando…'),
        body: const Center(child: CircularProgressIndicator(color: _secondaryColor)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar('Error'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: _errorColor),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar la solicitud',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(certifierRequestDetailProvider(widget.requestId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'Reintentar',
                    style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (request) => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar('Revisión de Certificación'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusHeader(request),
              const SizedBox(height: 16),
              _buildProjectCard(request),
              const SizedBox(height: 12),
              _buildObjectivesCard(request),
              const SizedBox(height: 12),
              _buildRoadmapCard(request),
              const SizedBox(height: 12),
              _buildDocumentsCard(request),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildAuditConclusionSection(auditAsync),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildCertificationSection(certificationAsync),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(String title) => AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _onSurfaceColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _onSurfaceColor,
          ),
        ),
      );

  // ── Audit conclusion (read-only) ──────────────────────────────────────────────

  Widget _buildAuditConclusionSection(AsyncValue<AuditEntity?> auditAsync) {
    return auditAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _secondaryColor),
        ),
      ),
      error: (e, _) => _errorBox('Error al cargar la auditoría: $e'),
      data: (audit) {
        if (audit?.conclusion == null) {
          return _card(
            title: 'Conclusión de Auditoría',
            icon: Icons.gavel_outlined,
            child: Text(
              'La auditoría no tiene conclusión registrada.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              ),
            ),
          );
        }
        return _buildAuditConclusionCard(audit!.conclusion!);
      },
    );
  }

  Widget _buildAuditConclusionCard(AuditConclusion conclusion) {
    final color = _recommendationColor(conclusion.recommendation);
    final icon = _recommendationIcon(conclusion.recommendation);

    return _card(
      title: 'Conclusión de Auditoría',
      icon: Icons.gavel_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      conclusion.recommendation.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      _fmtDate(conclusion.submittedAt),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Notas del auditor',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            conclusion.notes,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Certification section ─────────────────────────────────────────────────────

  Widget _buildCertificationSection(AsyncValue<CertificationEntity?> certAsync) {
    return certAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _secondaryColor),
        ),
      ),
      error: (e, _) => _errorBox('Error al cargar certificación: $e'),
      data: (certification) {
        if (certification != null) {
          return _buildCertificationResultCard(certification);
        }
        return _buildCertificationFormCard();
      },
    );
  }

  Widget _buildCertificationFormCard() {
    return _card(
      title: 'Decisión de Certificación',
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Revisá el proyecto y la conclusión de auditoría antes de decidir.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Notas (obligatorio)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Fundamentos de la decisión de certificación…',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF2F4F6),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _secondaryColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_issuing || _rejecting) ? null : _rejectCertification,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _errorColor,
                    side: BorderSide(
                      color: _rejecting ? _errorColor.withValues(alpha: 0.4) : _errorColor,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _rejecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _errorColor),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(
                    _rejecting ? 'Rechazando…' : 'Rechazar',
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_issuing || _rejecting) ? null : _issueCertificate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _issuing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.verified_outlined, size: 18),
                  label: Text(
                    _issuing ? 'Emitiendo…' : 'Emitir',
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationResultCard(CertificationEntity certification) {
    final issued = certification.status == CertificationStatus.issued;
    final color = issued ? _successColor : _errorColor;
    final icon = issued ? Icons.verified_outlined : Icons.cancel_outlined;
    final label = issued ? 'Certificado Emitido' : 'Certificación Rechazada';
    final date = certification.issuedAt ?? certification.createdAt;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceColor,
                      ),
                    ),
                    Text(
                      _fmtDate(date),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.75),
                      ),
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
                child: Text(
                  issued ? 'Emitido' : 'Rechazado',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (certification.notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Notas del certificador',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariantColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              certification.notes,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Request info cards ────────────────────────────────────────────────────────

  Widget _buildStatusHeader(CreditRequestEntity request) {
    final statusKey = request.status.name;
    final (label, color) = _statusMeta[statusKey] ?? ('Desconocido', const Color(0xFF9E9E9E));
    final date = request.submittedAt ?? request.createdAt;

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.assignment_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.id,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.submittedAt != null
                      ? 'Enviada el ${_fmtDate(date)}'
                      : 'Creada el ${_fmtDate(date)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _onSurfaceVariantColor.withValues(alpha: 0.8),
                  ),
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
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(CreditRequestEntity request) {
    final project = request.project;
    return _card(
      title: 'Proyecto',
      icon: Icons.water_drop_outlined,
      child: project == null
          ? Text(
              'Sin información de proyecto.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              ),
            )
          : Column(
              children: [
                _row('Nombre', project.name),
                _row('Ubicación', project.location),
                _row('Categoría', project.category.name),
                _row('Resumen', project.summary),
                _row('Inversión estimada', 'USD ${project.estimatedInvestment.toStringAsFixed(0)}'),
                _row('Impacto hídrico', project.expectedWaterImpact),
                _row('Créditos a emitir', '${request.creditAmount.toStringAsFixed(0)} m³'),
              ],
            ),
    );
  }

  Widget _buildObjectivesCard(CreditRequestEntity request) {
    final goal = request.project?.sustainabilityGoal;
    return _card(
      title: 'Objetivos de Sustentabilidad',
      icon: Icons.eco_outlined,
      child: goal == null
          ? Text(
              'Sin objetivos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              ),
            )
          : Column(
              children: [
                _row('Objetivo', goal.objective),
                _row('Descripción', goal.description),
                _row('Entorno beneficiado', goal.benefittedEnvironment),
              ],
            ),
    );
  }

  Widget _buildRoadmapCard(CreditRequestEntity request) {
    final phases = request.roadmap?.phases ?? [];
    return _card(
      title: 'Roadmap',
      icon: Icons.timeline_outlined,
      child: phases.isEmpty
          ? Text(
              'Sin fases.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              ),
            )
          : Column(
              children: phases
                  .map(
                    (phase) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phase.name,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _onSurfaceColor,
                                  ),
                                ),
                                Text(
                                  '${_fmtDate(phase.startDate)} → ${_fmtDate(phase.endDate)}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: _onSurfaceVariantColor.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildDocumentsCard(CreditRequestEntity request) {
    final docs = request.documents;
    return _card(
      title: 'Documentos',
      icon: Icons.attach_file_outlined,
      child: docs.isEmpty
          ? Text(
              'Sin documentos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              ),
            )
          : Column(
              children: docs
                  .map(
                    (doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 16, color: _secondaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc.type.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _onSurfaceColor,
                              ),
                            ),
                          ),
                          if (doc.storageUrl.isNotEmpty)
                            const Icon(Icons.check_circle_outline, size: 16, color: _successColor),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _secondaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _onSurfaceVariantColor.withValues(alpha: 0.75),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceColor,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF93000A), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF93000A)),
              ),
            ),
          ],
        ),
      );

  String _fmtDate(DateTime date) => DateFormat('d MMM yyyy', 'es').format(date);

  Color _recommendationColor(AuditRecommendation rec) => switch (rec) {
        AuditRecommendation.approve => _successColor,
        AuditRecommendation.reject => _errorColor,
        AuditRecommendation.needsMoreInfo => _warningColor,
      };

  IconData _recommendationIcon(AuditRecommendation rec) => switch (rec) {
        AuditRecommendation.approve => Icons.check_circle_outline,
        AuditRecommendation.reject => Icons.cancel_outlined,
        AuditRecommendation.needsMoreInfo => Icons.help_outline,
      };
}
