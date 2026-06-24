import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/document_type.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/company_requests_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';

// ── Labels ────────────────────────────────────────────────────────────────────
const _docTypeLabels = {
  DocumentType.technical:    'Documentación Técnica',
  DocumentType.environmental:'Documentación Ambiental',
  DocumentType.legal:        'Documentación Legal',
  DocumentType.financial:    'Documentación Financiera',
};

const _milestoneLabels = {
  Milestones.initialAudit:               'Auditoría inicial',
  Milestones.meterInstalation:           'Instalación de medidores',
  Milestones.infrastructureValidation:   'Validación de infraestructura',
  Milestones.operativeSistem:            'Sistema operativo',
  Milestones.firstWaterSavingRegistered: 'Primer ahorro hídrico',
  Milestones.ambientalReportGenerated:   'Reporte ambiental generado',
  Milestones.proyectFinalized:           'Proyecto finalizado',
  Milestones.impactVerificated:          'Impacto verificado',
  Milestones.proyectReadyToInssue:       'Listo para emisión',
};

// Status → (label, color)
const _statusMeta = <RequestStatus, (String, Color)>{
  RequestStatus.draft:      ('Borrador',       Color(0xFF9E9E9E)),
  RequestStatus.pending:    ('Pendiente',      Color(0xFFFF8F00)),
  RequestStatus.underAudit: ('En auditoría',   Color(0xFF1565C0)),
  RequestStatus.certified:  ('En Certificación', Color(0xFF2E7D32)),
  RequestStatus.insured:    ('Asegurado',      Color(0xFF00695C)),
  RequestStatus.valued:     ('Valorado',       Color(0xFF6A1B9A)),
  RequestStatus.published:  ('Publicado',      Color(0xFF1B5E20)),
  RequestStatus.rejected:   ('Rechazado',      Color(0xFFC62828)),
};

// Pipeline de etapas del proceso (sin draft)
const _pipeline = [
  (RequestStatus.pending,    'Revisión inicial', 'Administrador revisa la solicitud', Icons.manage_search_outlined),
  (RequestStatus.underAudit, 'Auditoría',        'Auditor verifica el proyecto',      Icons.verified_user_outlined),
  (RequestStatus.certified,  'Certificación',    'Certificadora aprueba el proyecto', Icons.workspace_premium_outlined),
  (RequestStatus.insured,    'Aseguramiento',    'Aseguradora carga el plan de seguro', Icons.security_outlined),
  (RequestStatus.valued,     'Valorización',     'Admin asigna valor a los créditos', Icons.monetization_on_outlined),
  (RequestStatus.published,  'Publicación',      'Créditos disponibles en el mercado', Icons.public_outlined),
];

// Orden para comparar progreso
const _statusOrder = [
  RequestStatus.draft,
  RequestStatus.pending,
  RequestStatus.underAudit,
  RequestStatus.certified,
  RequestStatus.insured,
  RequestStatus.valued,
  RequestStatus.published,
  RequestStatus.rejected,
];

class RequestTrackingScreen extends ConsumerStatefulWidget {
  const RequestTrackingScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends ConsumerState<RequestTrackingScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestTrackingProvider(widget.requestId));

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: DashboardTokens.onSurfaceVariantColor, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            const TopBarTitled(title: 'Seguimiento'),
          ],
        ),
        actions: [
          TopBarIconButton(
            icon: Icons.refresh,
            onTap: () => ref.invalidate(requestTrackingProvider(widget.requestId)),
          ),
        ],
      ),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: DashboardTokens.secondaryColor)),
        error: (e, _) => _ErrorBody(onRetry: () => ref.invalidate(requestTrackingProvider(widget.requestId))),
        data: (request) => IndexedStack(
          index: _tabIndex,
          children: [
            _ResumenTab(request: request),
            _RoadmapTab(request: request),
            _DocumentosTab(request: request),
            _HistorialTab(request: request),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _tabIndex,
        items: [
          DashboardNavItem(icon: Icons.info_outlined,        label: 'Resumen',    onTap: () => setState(() => _tabIndex = 0)),
          DashboardNavItem(icon: Icons.timeline_outlined,    label: 'Roadmap',    onTap: () => setState(() => _tabIndex = 1)),
          DashboardNavItem(icon: Icons.description_outlined, label: 'Documentos', onTap: () => setState(() => _tabIndex = 2)),
          DashboardNavItem(icon: Icons.history_outlined,     label: 'Historial',  onTap: () => setState(() => _tabIndex = 3)),
        ],
      ),
    );
  }
}

// ── TAB: Resumen ──────────────────────────────────────────────────────────────
class _ResumenTab extends StatelessWidget {
  const _ResumenTab({required this.request});
  final CreditRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusMeta[request.status] ?? ('Desconocido', DashboardTokens.outlineColor);
    final currentIndex = _statusOrder.indexOf(request.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.07),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(Icons.assignment_outlined, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado actual', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: DashboardTokens.onSurfaceVariantColor, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(statusLabel, style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: -0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detalles
          _sectionTitle('Detalles de la Solicitud'),
          const SizedBox(height: 12),
          _infoCard(children: [
            _row('ID Solicitud', request.id),
            _divider(),
            _row('Empresa', request.issuerCompanyId),
            _divider(),
            _row('Proyecto', request.project?.name ?? '—'),
            _divider(),
            _row('Créditos', request.creditAmount > 0 ? '${request.creditAmount.toStringAsFixed(0)} m³' : '—'),
            _divider(),
            _row('Creada', _fmtDate(request.createdAt)),
            if (request.submittedAt != null) ...[
              _divider(),
              _row('Enviada', _fmtDate(request.submittedAt!)),
            ],
          ]),
          const SizedBox(height: 24),

          // Pipeline
          _sectionTitle('Proceso de Aprobación'),
          const SizedBox(height: 12),
          ...List.generate(_pipeline.length, (i) {
            final (pipelineStatus, pipelineLabel, pipelineDesc, pipelineIcon) = _pipeline[i];
            final pipelineIndex = _statusOrder.indexOf(pipelineStatus);
            final isDone    = request.status != RequestStatus.rejected && currentIndex > pipelineIndex;
            final isActive  = currentIndex == pipelineIndex;
            final isRejected = request.status == RequestStatus.rejected;

            final Color circleColor;
            if (isRejected && isActive) {
              circleColor = DashboardTokens.errorColor;
            } else if (isDone) {
              circleColor = DashboardTokens.secondaryColor;
            } else if (isActive) {
              circleColor = DashboardTokens.cyanColor;
            } else {
              circleColor = DashboardTokens.outlineVariantColor;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor.withValues(alpha: isDone || isActive ? 1 : 0.15)),
                        child: Icon(
                          isDone ? Icons.check : pipelineIcon,
                          size: 18,
                          color: isDone || isActive ? Colors.white : DashboardTokens.outlineVariantColor,
                        ),
                      ),
                      if (i < _pipeline.length - 1)
                        Container(width: 2, height: 28, color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.4)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pipelineLabel, style: TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700, color: isActive ? DashboardTokens.primaryColor : DashboardTokens.onSurfaceVariantColor)),
                        Text(pipelineDesc, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.75))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── TAB: Roadmap ──────────────────────────────────────────────────────────────
class _RoadmapTab extends StatelessWidget {
  const _RoadmapTab({required this.request});
  final CreditRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final phases = request.roadmap?.phases ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Fases del Proyecto'),
          const SizedBox(height: 4),
          Text('${phases.length} fase${phases.length == 1 ? '' : 's'} definida${phases.length == 1 ? '' : 's'}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: DashboardTokens.onSurfaceVariantColor)),
          const SizedBox(height: 16),
          if (phases.isEmpty)
            _emptyState(Icons.timeline_outlined, 'Sin roadmap', 'No se han definido fases para este proyecto.')
          else
            ...List.generate(phases.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PhaseCard(phase: phases[i], index: i),
            )),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase, required this.index});
  final PhaseEntity phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: DashboardTokens.secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: Text('${index + 1}', style: const TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w700, color: DashboardTokens.secondaryColor))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(phase.name, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700, color: DashboardTokens.onSurfaceColor))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: DashboardTokens.onSurfaceVariantColor),
              const SizedBox(width: 6),
              Text(
                '${_fmtDate(phase.startDate)} → ${_fmtDate(phase.endDate)}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: DashboardTokens.onSurfaceVariantColor),
              ),
            ],
          ),
          if (phase.milestones.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: DashboardTokens.outlineVariantColor),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: phase.milestones.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DashboardTokens.secondaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: DashboardTokens.secondaryColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _milestoneLabels[m] ?? m.name,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: DashboardTokens.secondaryColor),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── TAB: Documentos ───────────────────────────────────────────────────────────
class _DocumentosTab extends StatelessWidget {
  const _DocumentosTab({required this.request});
  final CreditRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final docs = request.documents;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Documentos Enviados'),
          const SizedBox(height: 4),
          Text('${docs.length} de 4 documentos adjuntos',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: DashboardTokens.onSurfaceVariantColor)),
          const SizedBox(height: 16),
          if (docs.isEmpty)
            _emptyState(Icons.description_outlined, 'Sin documentos', 'No se han adjuntado documentos a esta solicitud.')
          else
            ...docs.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentCard(doc: doc),
            )),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc});
  final DocumentEntity doc;

  @override
  Widget build(BuildContext context) {
    final label = _docTypeLabels[doc.type] ?? doc.type.name;
    final hasUrl = doc.storageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: DashboardTokens.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.insert_drive_file_outlined, size: 22, color: DashboardTokens.secondaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700, color: DashboardTokens.onSurfaceColor)),
                const SizedBox(height: 2),
                Text(
                  'Subido el ${_fmtDate(doc.uploadedAt)}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: DashboardTokens.onSurfaceVariantColor),
                ),
              ],
            ),
          ),
          Icon(
            hasUrl ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 20,
            color: hasUrl ? const Color(0xFF2E7D32) : DashboardTokens.errorColor,
          ),
        ],
      ),
    );
  }
}

// ── TAB: Historial ────────────────────────────────────────────────────────────
class _HistorialTab extends StatelessWidget {
  const _HistorialTab({required this.request});
  final CreditRequestEntity request;

  List<(DateTime, String, String, IconData)> _buildEvents() {
    final events = <(DateTime, String, String, IconData)>[];
    events.add((request.createdAt, 'Solicitud creada', 'Borrador guardado en el sistema', Icons.add_circle_outline));
    if (request.submittedAt != null) {
      events.add((request.submittedAt!, 'Solicitud enviada', 'Estado cambiado a Pendiente', Icons.send_outlined));
    }
    if (request.status == RequestStatus.underAudit && request.updatedAt != null) {
      events.add((request.updatedAt!, 'Auditor asignado', 'Solicitud en proceso de auditoría', Icons.assignment_ind_outlined));
    }
    if (request.status == RequestStatus.rejected && request.updatedAt != null) {
      events.add((request.updatedAt!, 'Solicitud rechazada', 'La solicitud fue rechazada', Icons.cancel_outlined));
    }
    events.sort((a, b) => a.$1.compareTo(b.$1));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Historial de la Solicitud'),
          const SizedBox(height: 16),
          ...List.generate(events.length, (i) {
            final (date, title, desc, icon) = events[i];
            final isLast = i == events.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: DashboardTokens.secondaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 18, color: DashboardTokens.secondaryColor),
                    ),
                    if (!isLast)
                      Container(width: 2, height: 36, color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.4)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700, color: DashboardTokens.onSurfaceColor)),
                        const SizedBox(height: 2),
                        Text(desc, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: DashboardTokens.onSurfaceVariantColor)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM yyyy, HH:mm', 'es').format(date),
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: DashboardTokens.outlineColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: DashboardTokens.errorColor),
            const SizedBox(height: 16),
            const Text('No se pudo cargar la solicitud', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: DashboardTokens.onSurfaceColor)),
            const SizedBox(height: 8),
            const Text('Verificá tu conexión e intentá nuevamente.', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: DashboardTokens.onSurfaceVariantColor)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardTokens.primaryColor, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
Widget _sectionTitle(String text) => Text(text,
  style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: DashboardTokens.primaryColor, letterSpacing: -0.2));

Widget _infoCard({required List<Widget> children}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  decoration: BoxDecoration(
    color: DashboardTokens.surfaceLowestColor,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
);

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: DashboardTokens.onSurfaceVariantColor)),
      Flexible(
        child: Text(value.isEmpty ? '—' : value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: DashboardTokens.onSurfaceColor),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    ],
  ),
);

Widget _divider() => const Divider(height: 1, color: DashboardTokens.outlineVariantColor);

Widget _emptyState(IconData icon, String title, String desc) => Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: DashboardTokens.outlineVariantColor),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: DashboardTokens.onSurfaceColor)),
        const SizedBox(height: 6),
        Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: DashboardTokens.onSurfaceVariantColor, height: 1.4)),
      ],
    ),
  ),
);

String _fmtDate(DateTime date) => DateFormat('d MMM yyyy', 'es').format(date);
