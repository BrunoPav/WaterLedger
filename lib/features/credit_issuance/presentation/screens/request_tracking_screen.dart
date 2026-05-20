import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class RequestTrackingScreen extends ConsumerWidget {
  const RequestTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(creditRequestProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seguimiento de Solicitud'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outlined), text: 'Resumen'),
              Tab(icon: Icon(Icons.timeline), text: 'Roadmap'),
              Tab(icon: Icon(Icons.description_outlined), text: 'Documentos'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Historial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResumenTab(context, request),
            _buildRoadmapTab(request),
            _buildDocumentosTab(request),
            _buildHistorialTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenTab(BuildContext context, dynamic request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Estado Actual
          _buildStatusCard(request),
          const SizedBox(height: 24),

          // Detalles de la Solicitud
          const Text(
            'Detalles de la Solicitud',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailItem('ID Solicitud', request.id),
          _buildDetailItem('Empresa', request.issuerCompanyId),
          _buildDetailItem(
            'Fecha de Creación',
            DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt),
          ),
          if (request.updatedAt != null)
            _buildDetailItem(
              'Fecha de Envío',
              DateFormat('dd/MM/yyyy HH:mm').format(request.updatedAt!),
            ),
          const SizedBox(height: 24),

          // Próximas Etapas
          const Text(
            'Próximas Etapas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),
          _buildNextStepsTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(dynamic request) {
    final statusColor = _getStatusColor(request.status);
    final statusLabel = _getStatusLabel(request.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado Actual',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF44474D),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapTab(dynamic request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fases del Proyecto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 16),
          if (request.roadmap != null)
            _buildRoadmapTimeline(request.roadmap)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Roadmap no disponible',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentosTab(dynamic request) {
    final hasDocuments = request.documents.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documentos Enviados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 16),
          if (hasDocuments)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: request.documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final doc = request.documents[index];
                return _buildDocumentCard(doc);
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sin documentos enviados',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Cambios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 16),
          _buildHistoryTimeline(),
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF44474D),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsTimeline() {
    final steps = [
      ('Revisión Inicial', 'En progreso', Icons.schedule_outlined),
      ('Análisis Técnico', 'Pendiente', Icons.checklist_outlined),
      ('Auditoría', 'Pendiente', Icons.verified_user_outlined),
      ('Aprobación', 'Pendiente', Icons.check_circle_outline_rounded),
    ];

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final (label, status, icon) = steps[index];
          final isActive = index == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF00E3FD)
                            : Colors.grey[300],
                      ),
                      child: Icon(icon,
                          size: 20,
                          color: isActive ? Colors.white : Colors.grey[600]),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? const Color(0xFF00E3FD)
                            : const Color(0xFF44474D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoadmapTimeline(dynamic roadmap) {
    if (roadmap.phases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Sin fases definidas',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        roadmap.phases.length,
        (index) {
          final phase = roadmap.phases[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        phase.name ?? 'Fase ${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${phase.startDate != null ? 'Iniciado' : 'Próximo'}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hitos clave: ${phase.milestones.join(", ")}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(dynamic doc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 32, color: Color(0xFF006875)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName ?? 'Documento',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  doc.documentType.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF44474D),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    final historyItems = [
      ('Solicitud Creada', 'Borrador guardado', Icons.edit_outlined),
      ('Roadmap Actualizado', 'Fases definidas', Icons.timeline),
      ('Documentos Subidos', '3 documentos', Icons.upload_file_outlined),
      ('Solicitud Enviada', 'Cambio a Pendiente', Icons.send_outlined),
    ];

    return Column(
      children: List.generate(
        historyItems.length,
        (index) {
          final (title, desc, icon) = historyItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                  ),
                  child:
                      Icon(icon, size: 20, color: Colors.blue[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return Colors.grey[600]!;
      case RequestStatus.pending:
        return const Color(0xFF00E3FD);
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return 'BORRADOR';
      case RequestStatus.pending:
        return 'PENDIENTE';
      default:
        return status.name.toUpperCase();
    }
  }
}
