import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/valuation/domain/entities/valuation_entity.dart';
import 'package:water_ledger/features/valuation/domain/enums/valuation_status.dart';
import 'package:water_ledger/features/valuation/presentation/providers/valuation_repository_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);
const _errorColor            = Color(0xFFC62828);
const _successColor          = Color(0xFF2E7D32);
const _valuedColor           = Color(0xFF6A1B9A);
const _publishedColor        = Color(0xFF1B5E20);
const _insuredColor          = Color(0xFF00695C);

const _statusMeta = <String, (String, Color)>{
  'draft':      ('Borrador',      Color(0xFF9E9E9E)),
  'pending':    ('Pendiente',     Color(0xFFFF8F00)),
  'underAudit': ('En auditoría',  Color(0xFF1565C0)),
  'certified':  ('Certificado',   Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     _insuredColor),
  'valued':     ('Valorizado',    _valuedColor),
  'published':  ('Publicado',     _publishedColor),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

class AdminValuationDetailScreen extends ConsumerStatefulWidget {
  const AdminValuationDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AdminValuationDetailScreen> createState() =>
      _AdminValuationDetailScreenState();
}

class _AdminValuationDetailScreenState
    extends ConsumerState<AdminValuationDetailScreen> {
  final _assessedValueCtrl = TextEditingController();
  final _methodologyCtrl   = TextEditingController();
  final _notesCtrl         = TextEditingController();

  bool _appraising  = false;
  bool _rejecting   = false;
  bool _publishing  = false;

  @override
  void dispose() {
    _assessedValueCtrl.dispose();
    _methodologyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  double? get _parsedAssessedValue {
    final raw = _assessedValueCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(raw);
  }

  double _computePricePerCredit(double assessedValue, double creditAmount) {
    if (creditAmount <= 0) return 0;
    return assessedValue / creditAmount;
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _appraise(CreditRequestEntity request) async {
    final assessed = _parsedAssessedValue;
    if (assessed == null || assessed <= 0) {
      _showError('Ingresá un monto valorizado válido (mayor a 0).');
      return;
    }
    final methodology = _methodologyCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    if (notes.isEmpty) {
      _showError('Las notas son obligatorias.');
      return;
    }

    final confirmed = await _showConfirmDialog(
      action: 'Confirmar Valorización',
      message:
          '¿Confirmás la valorización de USD ${_fmt(assessed)} para esta solicitud? '
          'El estado pasará a "Valorizado".',
      confirmLabel: 'Valorizar',
      confirmColor: _valuedColor,
    );
    if (!confirmed || !mounted) return;

    final user = ref.read(sessionProvider).value;
    if (user == null) return;

    final pricePerCredit = _computePricePerCredit(assessed, request.creditAmount);

    setState(() => _appraising = true);
    try {
      await ref.read(valuationRepositoryProvider).createValuation(
            requestId: widget.requestId,
            adminId: user.uid,
            assessedValue: assessed,
            pricePerCredit: pricePerCredit,
            methodology: methodology,
            notes: notes,
          );
      if (!mounted) return;
      _showSnack('Valorización registrada correctamente ✓', _valuedColor);
      ref.invalidate(valuationRequestDetailProvider(widget.requestId));
      ref.invalidate(valuationStreamProvider(widget.requestId));
      ref.invalidate(insuredRequestsForAdminProvider);
      ref.invalidate(valuedRequestsForAdminProvider);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al valorizar: $e');
    } finally {
      if (mounted) setState(() => _appraising = false);
    }
  }

  Future<void> _reject() async {
    final notes = _notesCtrl.text.trim();
    if (notes.isEmpty) {
      _showError('Las notas son obligatorias antes de rechazar.');
      return;
    }
    final confirmed = await _showConfirmDialog(
      action: 'Rechazar Valorización',
      message: '¿Confirmás el rechazo? Esta acción no se puede deshacer.',
      confirmLabel: 'Rechazar',
      confirmColor: _errorColor,
    );
    if (!confirmed || !mounted) return;

    final user = ref.read(sessionProvider).value;
    if (user == null) return;

    setState(() => _rejecting = true);
    try {
      await ref.read(valuationRepositoryProvider).rejectValuation(
            requestId: widget.requestId,
            adminId: user.uid,
            notes: notes,
          );
      if (!mounted) return;
      _showSnack('Solicitud rechazada.', _errorColor);
      ref.invalidate(valuationRequestDetailProvider(widget.requestId));
      ref.invalidate(insuredRequestsForAdminProvider);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al rechazar: $e');
    } finally {
      if (mounted) setState(() => _rejecting = false);
    }
  }

  Future<void> _publish() async {
    final confirmed = await _showConfirmDialog(
      action: 'Publicar en Marketplace',
      message:
          '¿Confirmás la publicación de esta solicitud? '
          'Los créditos quedarán visibles en el marketplace.',
      confirmLabel: 'Publicar',
      confirmColor: _publishedColor,
    );
    if (!confirmed || !mounted) return;

    setState(() => _publishing = true);
    try {
      await ref.read(valuationRepositoryProvider).publishRequest(
            requestId: widget.requestId,
          );
      if (!mounted) return;
      _showSnack('Créditos publicados en el marketplace ✓', _publishedColor);
      ref.invalidate(valuationRequestDetailProvider(widget.requestId));
      ref.invalidate(valuedRequestsForAdminProvider);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al publicar: $e');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String action,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async =>
      await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(action,
                  style: const TextStyle(
                      fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
              content: Text(message,
                  style: const TextStyle(fontFamily: 'Inter')),
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

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _errorColor),
      );

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(valuationRequestDetailProvider(widget.requestId));
    final valuationAsync = ref.watch(valuationStreamProvider(widget.requestId));

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
                  onPressed: () =>
                      ref.invalidate(valuationRequestDetailProvider(widget.requestId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _onSurfaceColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar',
                      style: TextStyle(
                          fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (request) => Scaffold(
        backgroundColor: _bgColor,
        appBar: _appBar('Valorización del Crédito'),
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
              _buildValuationSection(request, valuationAsync),
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
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor)),
      );

  // ── Status header ─────────────────────────────────────────────────────────────

  Widget _buildStatusHeader(CreditRequestEntity request) {
    final statusKey = request.status.name;
    final (label, color) =
        _statusMeta[statusKey] ?? ('Desconocido', const Color(0xFF9E9E9E));
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
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child:
                Icon(Icons.assignment_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.id,
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceColor)),
                const SizedBox(height: 2),
                Text(
                  request.submittedAt != null
                      ? 'Enviada el ${_fmtDate(date)}'
                      : 'Creada el ${_fmtDate(date)}',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color:
                          _onSurfaceVariantColor.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }

  // ── Info cards ────────────────────────────────────────────────────────────────

  Widget _buildProjectCard(CreditRequestEntity request) {
    final project = request.project;
    return _card(
      title: 'Proyecto',
      icon: Icons.water_drop_outlined,
      child: project == null
          ? _empty('Sin información de proyecto.')
          : Column(children: [
              _row('Nombre', project.name),
              _row('Ubicación', project.location),
              _row('Categoría', project.category.name),
              _row('Resumen', project.summary),
              _row('Inversión estimada',
                  'USD ${project.estimatedInvestment.toStringAsFixed(0)}'),
              _row('Impacto hídrico', project.expectedWaterImpact),
              _row('Créditos a emitir',
                  '${request.creditAmount.toStringAsFixed(0)} m³'),
            ]),
    );
  }

  Widget _buildObjectivesCard(CreditRequestEntity request) {
    final goal = request.project?.sustainabilityGoal;
    return _card(
      title: 'Objetivos de Sustentabilidad',
      icon: Icons.eco_outlined,
      child: goal == null
          ? _empty('Sin objetivos.')
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
          ? _empty('Sin fases.')
          : Column(
              children: phases
                  .map((phase) => Padding(
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
                                  Text(phase.name,
                                      style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _onSurfaceColor)),
                                  Text(
                                      '${_fmtDate(phase.startDate)} → ${_fmtDate(phase.endDate)}',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: _onSurfaceVariantColor
                                              .withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
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
          ? _empty('Sin documentos.')
          : Column(
              children: docs
                  .map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 16, color: _secondaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(doc.type.name,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _onSurfaceColor)),
                            ),
                            if (doc.storageUrl.isNotEmpty)
                              const Icon(Icons.check_circle_outline,
                                  size: 16, color: _successColor),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }

  // ── Valuation section ─────────────────────────────────────────────────────────

  Widget _buildValuationSection(
    CreditRequestEntity request,
    AsyncValue<ValuationEntity?> valuationAsync,
  ) {
    return valuationAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _secondaryColor),
        ),
      ),
      error: (e, _) => _errorBox('Error al cargar valorización: $e'),
      data: (valuation) {
        if (valuation != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildValuationResultCard(valuation),
              if (request.status == RequestStatus.valued) ...[
                const SizedBox(height: 16),
                _buildPublishCard(),
              ],
            ],
          );
        }
        if (request.status == RequestStatus.insured) {
          return _buildValuationFormCard(request);
        }
        return _card(
          title: 'Valorización',
          icon: Icons.analytics_outlined,
          child: _empty('Esta solicitud no está en estado de valorización.'),
        );
      },
    );
  }

  Widget _buildValuationFormCard(CreditRequestEntity request) {
    return _card(
      title: 'Decisión de Valorización',
      icon: Icons.analytics_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Revisá el proyecto y definí el valor económico de los créditos hídricos antes de proceder.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Monto valorizado
          _fieldLabel('Monto valorizado (USD) *'),
          const SizedBox(height: 8),
          TextField(
            controller: _assessedValueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              hint: 'Ej: 250000',
              suffix: _parsedAssessedValue != null && request.creditAmount > 0
                  ? Text(
                      'USD ${_fmt(_computePricePerCredit(_parsedAssessedValue!, request.creditAmount))}/m³',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
          if (_parsedAssessedValue != null && request.creditAmount > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Precio por crédito: USD ${_fmt(_computePricePerCredit(_parsedAssessedValue!, request.creditAmount))} / m³  •  ${request.creditAmount.toStringAsFixed(0)} m³ totales',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _secondaryColor.withValues(alpha: 0.85),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Metodología
          _fieldLabel('Metodología de valorización'),
          const SizedBox(height: 8),
          TextField(
            controller: _methodologyCtrl,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: _inputDecoration(
              hint: 'Ej: Valor de mercado comparable, enfoque de ingresos…',
            ),
          ),

          const SizedBox(height: 16),

          // Notas
          _fieldLabel('Fundamentos y notas *'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            decoration: _inputDecoration(
              hint: 'Detalle el criterio utilizado para la valorización…',
            ),
          ),

          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_appraising || _rejecting) ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _errorColor,
                    side: BorderSide(
                        color: _rejecting
                            ? _errorColor.withValues(alpha: 0.4)
                            : _errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _rejecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _errorColor),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(
                    _rejecting ? 'Rechazando…' : 'Rechazar',
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_appraising || _rejecting)
                      ? null
                      : () => _appraise(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _valuedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _appraising
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.price_check_outlined, size: 18),
                  label: Text(
                    _appraising ? 'Valorizando…' : 'Valorizar',
                    style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValuationResultCard(ValuationEntity valuation) {
    final approved = valuation.status == ValuationStatus.appraised;
    final color = approved ? _valuedColor : _errorColor;
    final icon =
        approved ? Icons.price_check_outlined : Icons.cancel_outlined;
    final label =
        approved ? 'Valorización Registrada' : 'Valorización Rechazada';
    final date = valuation.appraisedAt ?? valuation.createdAt;

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
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _onSurfaceColor)),
                    Text(_fmtDate(date),
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _onSurfaceVariantColor
                                .withValues(alpha: 0.75))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  approved ? 'Valorizado' : 'Rechazado',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ],
          ),
          if (approved) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            _row('Monto valorizado',
                'USD ${_fmt(valuation.assessedValue)}'),
            _row('Precio por crédito',
                'USD ${_fmt(valuation.pricePerCredit)} / m³'),
            if (valuation.methodology.isNotEmpty)
              _row('Metodología', valuation.methodology),
          ],
          if (valuation.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              approved ? 'Fundamentos' : 'Motivo del rechazo',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariantColor),
            ),
            const SizedBox(height: 6),
            Text(valuation.notes,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _onSurfaceColor,
                    height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildPublishCard() {
    return _card(
      title: 'Publicación en Marketplace',
      icon: Icons.storefront_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'La solicitud está valorizada y lista para publicarse. '
            'Al publicar, los créditos hídricos quedarán disponibles en el marketplace para inversores.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _publishing ? null : _publish,
            style: ElevatedButton.styleFrom(
              backgroundColor: _publishedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: _publishing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.publish_outlined, size: 18),
            label: Text(
              _publishing ? 'Publicando…' : 'Publicar en Marketplace',
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: _secondaryColor, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _onSurfaceColor)),
            ]),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color:
                          _onSurfaceVariantColor.withValues(alpha: 0.75))),
            ),
            Expanded(
              child: Text(value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceColor)),
            ),
          ],
        ),
      );

  Widget _empty(String msg) => Text(msg,
      style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _onSurfaceVariantColor.withValues(alpha: 0.8)));

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
              child: Text(msg,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF93000A))),
            ),
          ],
        ),
      );

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _onSurfaceVariantColor));

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: _onSurfaceVariantColor.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: _outlineVariantColor.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _secondaryColor, width: 1.5),
        ),
      );

  String _fmtDate(DateTime date) =>
      DateFormat('d MMM yyyy', 'es').format(date);

  String _fmt(double value) {
    final nf = NumberFormat('#,##0.00', 'es');
    return nf.format(value);
  }
}
