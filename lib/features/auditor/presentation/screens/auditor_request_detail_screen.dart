import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_recommendation.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_status.dart';
import 'package:water_ledger/features/auditor/domain/enums/observation_type.dart';
import 'package:water_ledger/features/auditor/presentation/providers/audit_repository_provider.dart';
import 'package:water_ledger/features/auditor/presentation/providers/auditor_provider.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
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
  'certified':  ('Certificado',   Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     Color(0xFF00695C)),
  'valued':     ('Valorado',      Color(0xFF6A1B9A)),
  'published':  ('Publicado',     Color(0xFF1B5E20)),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

class AuditorRequestDetailScreen extends ConsumerStatefulWidget {
  const AuditorRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AuditorRequestDetailScreen> createState() =>
      _AuditorRequestDetailScreenState();
}

class _AuditorRequestDetailScreenState
    extends ConsumerState<AuditorRequestDetailScreen> {
  bool _starting = false;
  bool _deletingObsId = false;

  // ── Observation form state ──────────────────────────────────────────────────
  final _obsTextCtrl = TextEditingController();
  ObservationType _obsType = ObservationType.general;
  bool _addingObs = false;

  // ── Conclusion form state ───────────────────────────────────────────────────
  AuditRecommendation _recommendation = AuditRecommendation.approve;
  final _conclusionNotesCtrl = TextEditingController();
  bool _submittingConclusion = false;

  @override
  void dispose() {
    _obsTextCtrl.dispose();
    _conclusionNotesCtrl.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _startAudit() async {
    final user = ref.read(sessionProvider).value;
    if (user == null) return;
    setState(() => _starting = true);
    try {
      await ref.read(startAuditUseCaseProvider).call(
            requestId: widget.requestId,
            auditorId: user.uid,
          );
    } catch (e) {
      if (!mounted) return;
      _showError('Error al iniciar auditoría: $e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _addObservation() async {
    final text = _obsTextCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _addingObs = true);
    try {
      final obs = AuditObservation(
        id: 'obs_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        type: _obsType,
        createdAt: DateTime.now(),
      );
      await ref.read(addObservationUseCaseProvider).call(
            requestId: widget.requestId,
            observation: obs,
          );
      _obsTextCtrl.clear();
      setState(() => _obsType = ObservationType.general);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al agregar observación: $e');
    } finally {
      if (mounted) setState(() => _addingObs = false);
    }
  }

  Future<void> _deleteObservation(String obsId) async {
    setState(() => _deletingObsId = true);
    try {
      await ref.read(deleteObservationUseCaseProvider).call(
            requestId: widget.requestId,
            observationId: obsId,
          );
    } catch (e) {
      if (!mounted) return;
      _showError('Error al eliminar observación: $e');
    } finally {
      if (mounted) setState(() => _deletingObsId = false);
    }
  }

  Future<void> _submitConclusion() async {
    final notes = _conclusionNotesCtrl.text.trim();
    if (notes.isEmpty) {
      _showError('Las notas de conclusión son obligatorias.');
      return;
    }
    final confirmed = await _showConclusionConfirmDialog();
    if (!confirmed || !mounted) return;

    setState(() => _submittingConclusion = true);
    try {
      final conclusion = AuditConclusion(
        recommendation: _recommendation,
        notes: notes,
        submittedAt: DateTime.now(),
      );
      await ref.read(submitAuditConclusionUseCaseProvider).call(
            requestId: widget.requestId,
            conclusion: conclusion,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auditoría enviada correctamente ✓'),
          backgroundColor: _successColor,
          duration: Duration(seconds: 3),
        ),
      );
      // Invalidar el detalle para reflejar el nuevo estado
      ref.invalidate(auditorRequestDetailProvider(widget.requestId));
    } catch (e) {
      if (!mounted) return;
      _showError('Error al enviar conclusión: $e');
    } finally {
      if (mounted) setState(() => _submittingConclusion = false);
    }
  }

  Future<bool> _showConclusionConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'Confirmar envío',
              style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Recomendación: ${_recommendation.label}.\n\nEsta acción no se puede deshacer.',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar auditoría'),
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
    final requestAsync = ref.watch(auditorRequestDetailProvider(widget.requestId));
    final auditAsync = ref.watch(auditStreamProvider(widget.requestId));

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
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: _onSurfaceColor),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(auditorRequestDetailProvider(widget.requestId)),
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (request) => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar('Detalle de Auditoría'),
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
              _buildAuditSection(auditAsync),
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
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: _onSurfaceColor),
        ),
      );

  // ── Audit section ─────────────────────────────────────────────────────────────

  Widget _buildAuditSection(AsyncValue<AuditEntity?> auditAsync) {
    return auditAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _secondaryColor),
        ),
      ),
      error: (e, _) => _errorBox('Error al cargar la auditoría: $e'),
      data: (audit) {
        if (audit == null) return _buildStartAuditCard();
        if (audit.status == AuditStatus.submitted) return _buildSubmittedAudit(audit);
        return _buildInProgressAudit(audit);
      },
    );
  }

  // ── Start audit ───────────────────────────────────────────────────────────────

  Widget _buildStartAuditCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _secondaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rate_review_outlined, color: _secondaryColor, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Iniciar Auditoría',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700, color: _onSurfaceColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Comenzá la revisión de esta solicitud. Podrás registrar observaciones y emitir una conclusión final.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.85), height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _starting ? null : _startAudit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: _starting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow_outlined, size: 20),
              label: Text(
                _starting ? 'Iniciando…' : 'Iniciar Auditoría',
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── In-progress audit ─────────────────────────────────────────────────────────

  Widget _buildInProgressAudit(AuditEntity audit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // header status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_outlined, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Auditoría en curso',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
              ),
              const Spacer(),
              Text(
                '${audit.observations.length} obs.',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildObservationsCard(audit, readOnly: false),
        const SizedBox(height: 16),
        _buildAddObservationCard(),
        const SizedBox(height: 16),
        _buildConclusionFormCard(),
      ],
    );
  }

  // ── Submitted audit ───────────────────────────────────────────────────────────

  Widget _buildSubmittedAudit(AuditEntity audit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildConclusionResultCard(audit.conclusion!),
        if (audit.observations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildObservationsCard(audit, readOnly: true),
        ],
      ],
    );
  }

  // ── Observations card ─────────────────────────────────────────────────────────

  Widget _buildObservationsCard(AuditEntity audit, {required bool readOnly}) {
    return _card(
      title: 'Observaciones',
      icon: Icons.comment_outlined,
      child: audit.observations.isEmpty
          ? Text(
              'Sin observaciones registradas.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)),
            )
          : Column(
              children: audit.observations.map((obs) {
                final typeColor = _obsTypeColor(obs.type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            obs.type.label,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: typeColor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(obs.text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceColor, height: 1.4)),
                              const SizedBox(height: 4),
                              Text(
                                _fmtDate(obs.createdAt),
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                        if (!readOnly)
                          GestureDetector(
                            onTap: _deletingObsId ? null : () => _deleteObservation(obs.id),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.delete_outline, size: 18, color: _onSurfaceVariantColor.withValues(alpha: 0.6)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ── Add observation form ──────────────────────────────────────────────────────

  Widget _buildAddObservationCard() {
    return _card(
      title: 'Agregar Observación',
      icon: Icons.add_comment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.4)),
            ),
            child: DropdownButton<ObservationType>(
              value: _obsType,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceColor),
              items: ObservationType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _obsType = v!),
            ),
          ),
          const SizedBox(height: 12),
          // Texto
          TextField(
            controller: _obsTextCtrl,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describí la observación…',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.5)),
              filled: true,
              fillColor: const Color(0xFFF2F4F6),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _addingObs ? null : _addObservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _addingObs
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add, size: 18),
              label: Text(
                _addingObs ? 'Guardando…' : 'Agregar',
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Conclusion form ───────────────────────────────────────────────────────────

  Widget _buildConclusionFormCard() {
    return _card(
      title: 'Conclusión Final',
      icon: Icons.gavel_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recomendación',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor),
          ),
          const SizedBox(height: 8),
          ...AuditRecommendation.values.map((rec) {
            final selected = _recommendation == rec;
            final color = _recommendationColor(rec);
            return GestureDetector(
              onTap: () => setState(() => _recommendation = rec),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.08) : const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color.withValues(alpha: 0.4) : _outlineVariantColor.withValues(alpha: 0.3),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: selected ? color : _onSurfaceVariantColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      rec.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected ? color : _onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'Notas (obligatorio)',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _conclusionNotesCtrl,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describí los fundamentos de la conclusión…',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.5)),
              filled: true,
              fillColor: const Color(0xFFF2F4F6),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submittingConclusion ? null : _submitConclusion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: _submittingConclusion
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                _submittingConclusion ? 'Enviando…' : 'Enviar Auditoría',
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Conclusion result (read-only) ─────────────────────────────────────────────

  Widget _buildConclusionResultCard(AuditConclusion conclusion) {
    final color = _recommendationColor(conclusion.recommendation);
    final icon = _recommendationIcon(conclusion.recommendation);

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
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auditoría Completada',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700, color: _onSurfaceColor),
                  ),
                  Text(
                    _fmtDate(conclusion.submittedAt),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  conclusion.recommendation.label,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Notas del auditor',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor),
          ),
          const SizedBox(height: 6),
          Text(
            conclusion.notes,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Existing request cards (unchanged) ────────────────────────────────────────

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
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.assignment_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.id, style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
                const SizedBox(height: 2),
                Text(
                  request.submittedAt != null ? 'Enviada el ${_fmtDate(date)}' : 'Creada el ${_fmtDate(date)}',
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

  Widget _buildProjectCard(CreditRequestEntity request) {
    final project = request.project;
    return _card(
      title: 'Proyecto',
      icon: Icons.water_drop_outlined,
      child: project == null
          ? Text('Sin información de proyecto.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)))
          : Column(children: [
              _row('Nombre', project.name),
              _row('Ubicación', project.location),
              _row('Categoría', project.category.name),
              _row('Resumen', project.summary),
              _row('Inversión estimada', 'USD ${project.estimatedInvestment.toStringAsFixed(0)}'),
              _row('Impacto hídrico', project.expectedWaterImpact),
              _row('Créditos a emitir', '${request.creditAmount.toStringAsFixed(0)} m³'),
            ]),
    );
  }

  Widget _buildObjectivesCard(CreditRequestEntity request) {
    final goal = request.project?.sustainabilityGoal;
    return _card(
      title: 'Objetivos de Sustentabilidad',
      icon: Icons.eco_outlined,
      child: goal == null
          ? Text('Sin objetivos.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)))
          : Column(children: [
              _row('Objetivo', goal.objective),
              _row('Descripción', goal.description),
              _row('Entorno beneficiado', goal.benefittedEnvironment),
            ]),
    );
  }

  Widget _buildRoadmapCard(CreditRequestEntity request) {
    final phases = request.roadmap?.phases ?? [];
    return _card(
      title: 'Roadmap',
      icon: Icons.timeline_outlined,
      child: phases.isEmpty
          ? Text('Sin fases.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)))
          : Column(
              children: phases.map((phase) => Padding(
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
                          Text(phase.name, style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceColor)),
                          Text(
                            '${_fmtDate(phase.startDate)} → ${_fmtDate(phase.endDate)}',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
    );
  }

  Widget _buildDocumentsCard(CreditRequestEntity request) {
    final docs = request.documents;
    return _card(
      title: 'Documentos',
      icon: Icons.attach_file_outlined,
      child: docs.isEmpty
          ? Text('Sin documentos.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.8)))
          : Column(
              children: docs.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: _secondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(doc.type.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: _onSurfaceColor)),
                    ),
                    if (doc.storageUrl.isNotEmpty)
                      const Icon(Icons.check_circle_outline, size: 16, color: _successColor),
                  ],
                ),
              )).toList(),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: _secondaryColor, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
          ]),
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
              child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.75))),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: _onSurfaceColor),
              ),
            ),
          ],
        ),
      );

  Widget _errorBox(String msg) => Container(
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

  String _fmtDate(DateTime date) => DateFormat('d MMM yyyy', 'es').format(date);

  Color _obsTypeColor(ObservationType type) => switch (type) {
        ObservationType.general => const Color(0xFF006875),
        ObservationType.technical => const Color(0xFF1565C0),
        ObservationType.environmental => const Color(0xFF2E7D32),
        ObservationType.financial => const Color(0xFF6A1B9A),
      };

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
