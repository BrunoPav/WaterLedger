import 'package:water_ledger/features/auditor/domain/enums/audit_recommendation.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_status.dart';
import 'package:water_ledger/features/auditor/domain/enums/observation_type.dart';

class AuditObservation {
  final String id;
  final String text;
  final ObservationType type;
  final String? phase;
  final DateTime createdAt;

  const AuditObservation({
    required this.id,
    required this.text,
    required this.type,
    this.phase,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'type': type.name,
        if (phase != null) 'phase': phase,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuditObservation.fromMap(Map<String, dynamic> map) => AuditObservation(
        id: map['id'] as String,
        text: map['text'] as String,
        type: ObservationType.fromString(map['type'] as String? ?? 'general'),
        phase: map['phase'] as String?,
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt'] as String),
      );
}

class AuditConclusion {
  final AuditRecommendation recommendation;
  final String notes;
  final DateTime submittedAt;

  const AuditConclusion({
    required this.recommendation,
    required this.notes,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() => {
        'recommendation': recommendation.name,
        'notes': notes,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory AuditConclusion.fromMap(Map<String, dynamic> map) => AuditConclusion(
        recommendation: AuditRecommendation.fromString(
          map['recommendation'] as String? ?? 'needsMoreInfo',
        ),
        notes: map['notes'] as String? ?? '',
        submittedAt: map['submittedAt'] is DateTime
            ? map['submittedAt'] as DateTime
            : DateTime.parse(map['submittedAt'] as String),
      );
}

class AuditEntity {
  final String requestId;
  final String auditorId;
  final AuditStatus status;
  final List<AuditObservation> observations;
  final AuditConclusion? conclusion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuditEntity({
    required this.requestId,
    required this.auditorId,
    required this.status,
    required this.observations,
    this.conclusion,
    required this.createdAt,
    required this.updatedAt,
  });

  AuditEntity copyWith({
    AuditStatus? status,
    List<AuditObservation>? observations,
    AuditConclusion? conclusion,
    DateTime? updatedAt,
  }) =>
      AuditEntity(
        requestId: requestId,
        auditorId: auditorId,
        status: status ?? this.status,
        observations: observations ?? this.observations,
        conclusion: conclusion ?? this.conclusion,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'auditorId': auditorId,
        'status': status.name,
        'observations': observations.map((o) => o.toMap()).toList(),
        if (conclusion != null) 'conclusion': conclusion!.toMap(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AuditEntity.fromMap(Map<String, dynamic> map) => AuditEntity(
        requestId: map['requestId'] as String,
        auditorId: map['auditorId'] as String,
        status: AuditStatus.fromString(map['status'] as String? ?? 'inProgress'),
        observations: (map['observations'] as List<dynamic>? ?? [])
            .map((o) => AuditObservation.fromMap(o as Map<String, dynamic>))
            .toList(),
        conclusion: map['conclusion'] != null
            ? AuditConclusion.fromMap(map['conclusion'] as Map<String, dynamic>)
            : null,
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] is DateTime
            ? map['updatedAt'] as DateTime
            : DateTime.parse(map['updatedAt'] as String),
      );
}
