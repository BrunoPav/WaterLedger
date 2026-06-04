import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registro genérico de actividad reciente — usado por todos los dashboards.
class ActivityRecord {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const ActivityRecord({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

// ── Helpers comunes ────────────────────────────────────────────────────────────

List<ActivityRecord> _sortedAndLimited(List<ActivityRecord> items, {int limit = 5}) {
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(limit).toList();
}

DateTime _tsToDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}

// ── Company — últimas creditRequests actualizadas ──────────────────────────────

IconData _requestStatusIcon(String status) => switch (status) {
      'pending'    => Icons.hourglass_top_outlined,
      'underAudit' => Icons.search_outlined,
      'certified'  => Icons.verified_outlined,
      'insured'    => Icons.security_outlined,
      'valued'     => Icons.analytics_outlined,
      'published'  => Icons.storefront_outlined,
      'rejected'   => Icons.cancel_outlined,
      _            => Icons.assignment_outlined,
    };

String _requestStatusTitle(String status) => switch (status) {
      'pending'    => 'Solicitud enviada',
      'underAudit' => 'En proceso de auditoría',
      'certified'  => 'Solicitud certificada',
      'insured'    => 'Solicitud asegurada',
      'valued'     => 'Solicitud valorizada',
      'published'  => 'Créditos publicados',
      'rejected'   => 'Solicitud rechazada',
      _            => 'Solicitud actualizada',
    };

final companyActivityProvider =
    StreamProvider.autoDispose.family<List<ActivityRecord>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('creditRequests')
      .where('issuerCompanyId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final items = snap.docs
        .where((d) => d.data()['status'] != 'draft')
        .map((doc) {
          final data = doc.data();
          final status = data['status'] as String? ?? '';
          final project = data['project'] as Map<String, dynamic>?;
          final name = (project?['name'] as String?)?.trim().isNotEmpty == true
              ? project!['name'] as String
              : doc.id;
          final when = _tsToDate(
            data['updatedAt'] ?? data['submittedAt'] ?? data['createdAt'],
          );
          return ActivityRecord(
            icon: _requestStatusIcon(status),
            title: _requestStatusTitle(status),
            subtitle: name,
            timestamp: when,
          );
        })
        .toList();
    return _sortedAndLimited(items);
  });
});

// ── Auditor — últimas audits iniciadas / completadas ──────────────────────────

final auditorActivityProvider =
    StreamProvider.autoDispose.family<List<ActivityRecord>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('audits')
      .where('auditorId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final items = snap.docs.map((doc) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      final requestId = data['requestId'] as String? ?? doc.id;
      final when = _tsToDate(data['updatedAt'] ?? data['createdAt']);
      final isSubmitted = status == 'submitted';
      return ActivityRecord(
        icon: isSubmitted ? Icons.gavel_outlined : Icons.manage_search_outlined,
        title: isSubmitted ? 'Auditoría completada' : 'Auditoría iniciada',
        subtitle: requestId,
        timestamp: when,
      );
    }).toList();
    return _sortedAndLimited(items);
  });
});

// ── Certifier — últimas certifications emitidas / rechazadas ──────────────────

final certifierActivityProvider =
    StreamProvider.autoDispose.family<List<ActivityRecord>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('certifications')
      .where('certifierId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final items = snap.docs.map((doc) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      final requestId = data['requestId'] as String? ?? doc.id;
      final when = _tsToDate(
        data['issuedAt'] ?? data['createdAt'],
      );
      final isIssued = status == 'issued';
      return ActivityRecord(
        icon: isIssued ? Icons.verified_outlined : Icons.cancel_outlined,
        title: isIssued ? 'Certificado emitido' : 'Certificación rechazada',
        subtitle: requestId,
        timestamp: when,
      );
    }).toList();
    return _sortedAndLimited(items);
  });
});

// ── Insurer — últimas insurance plans creadas ─────────────────────────────────

final insurerActivityProvider =
    StreamProvider.autoDispose.family<List<ActivityRecord>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('insurancePlans')
      .where('insurerId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final items = snap.docs.map((doc) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      final requestId = data['requestId'] as String? ?? doc.id;
      final when = _tsToDate(data['createdAt']);
      final isActive = status == 'active';
      return ActivityRecord(
        icon: isActive ? Icons.security_outlined : Icons.cancel_outlined,
        title: isActive ? 'Plan de seguro creado' : 'Seguro rechazado',
        subtitle: requestId,
        timestamp: when,
      );
    }).toList();
    return _sortedAndLimited(items);
  });
});
