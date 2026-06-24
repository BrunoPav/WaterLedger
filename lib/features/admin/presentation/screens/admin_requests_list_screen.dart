import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/admin/presentation/providers/admin_provider.dart';

// ── Design tokens (shared with AdminDashboardScreen) ──────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);

// Estado → label en español + color del badge
const _statusMeta = <String, (String, Color)>{
  'draft':      ('Borrador',      Color(0xFF9E9E9E)),
  'pending':    ('Pendiente',     Color(0xFFFF8F00)),
  'underAudit': ('En auditoría',  Color(0xFF1565C0)),
  'certified':  ('En Certificación', Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     Color(0xFF00695C)),
  'valued':     ('Valorado',      Color(0xFF6A1B9A)),
  'published':  ('Publicado',     Color(0xFF1B5E20)),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

class AdminRequestsListScreen extends ConsumerStatefulWidget {
  const AdminRequestsListScreen({super.key});

  @override
  ConsumerState<AdminRequestsListScreen> createState() =>
      _AdminRequestsListScreenState();
}

class _AdminRequestsListScreenState
    extends ConsumerState<AdminRequestsListScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(allCreditRequestsProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _onSurfaceColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Solicitudes de Crédito',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _onSurfaceColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildStatusFilter(),
        ),
      ),
      body: requestsAsync.when(
        data: (all) {
          final filtered = _filterStatus == 'all'
              ? all
              : all.where((r) => r['status'] == _filterStatus).toList();

          if (filtered.isEmpty) {
            return _emptyState();
          }
          return RefreshIndicator(
            color: _secondaryColor,
            onRefresh: () async => ref.invalidate(allCreditRequestsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _requestCard(context, filtered[i]),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _secondaryColor),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(fontFamily: 'Inter', color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final options = [
      ('all', 'Todas'),
      ('pending', 'Pendientes'),
      ('underAudit', 'En auditoría'),
      ('certified', 'En certificación'),
      ('rejected', 'Rechazadas'),
    ];
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: options.map((opt) {
          final selected = _filterStatus == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(opt.$2),
              selected: selected,
              onSelected: (_) => setState(() => _filterStatus = opt.$1),
              selectedColor: _secondaryColor,
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _onSurfaceVariantColor,
              ),
              backgroundColor: _surfaceColor,
              side: BorderSide(
                color: selected ? _secondaryColor : _outlineVariantColor.withValues(alpha: 0.5),
              ),
              shape: const StadiumBorder(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _requestCard(BuildContext context, Map<String, dynamic> req) {
    final id = req['id'] as String? ?? '—';
    final status = req['status'] as String? ?? 'draft';
    final project = req['project'] as Map<String, dynamic>?;
    final projectName = project?['name'] as String? ?? 'Sin nombre';
    final companyId = req['issuerCompanyId'] as String? ?? '—';
    final createdAt = req['createdAt'];
    final submittedAt = req['submittedAt'];
    final assignedAuditor = req['assignedAuditorName'] as String?;

    final (statusLabel, statusColor) =
        _statusMeta[status] ?? ('Desconocido', const Color(0xFF9E9E9E));

    return InkWell(
      onTap: () => context.push('/admin-request-detail/$id'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                        projectName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: $id',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _onSurfaceVariantColor.withValues(alpha: 0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.business_outlined, _shortId(companyId)),
                const SizedBox(width: 10),
                if (submittedAt != null)
                  _infoChip(Icons.send_outlined, _fmtDate(submittedAt))
                else if (createdAt != null)
                  _infoChip(Icons.calendar_today_outlined, _fmtDate(createdAt)),
                if (assignedAuditor != null) ...[
                  const SizedBox(width: 10),
                  _infoChip(Icons.assignment_ind_outlined, assignedAuditor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _onSurfaceVariantColor.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: _onSurfaceVariantColor.withValues(alpha: 0.35)),
          const SizedBox(height: 12),
          Text(
            _filterStatus == 'all'
                ? 'No hay solicitudes aún'
                : 'Sin solicitudes con ese estado',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(dynamic value) {
    if (value is DateTime) {
      return DateFormat('d MMM yyyy', 'es').format(value);
    }
    return '—';
  }

  String _shortId(String uid) =>
      uid.length > 8 ? '${uid.substring(0, 8)}…' : uid;
}
