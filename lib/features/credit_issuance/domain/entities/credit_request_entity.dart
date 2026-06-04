import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

class CreditRequestEntity {
  String id;
  String issuerCompanyId;
  String proyectoId;
  double creditAmount;
  RequestStatus status;
  List<DocumentEntity> documents = [];
  RoadmapEntity? roadmap;
  WaterProjectEntity? project;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? submittedAt;

  CreditRequestEntity({
    required this.id,
    required this.issuerCompanyId,
    required this.proyectoId,
    required this.creditAmount,
    this.status = RequestStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.project,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'issuerCompanyId': issuerCompanyId,
    'creditAmount': creditAmount,
    'status': status.name,
    'documents': documents.map((d) => d.toMap()).toList(),
    if (roadmap != null) 'roadmap': roadmap!.toMap(),
    if (project != null) 'project': project!.toMap(),
    'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
    if (submittedAt != null) 'submittedAt': submittedAt,
  };

  factory CreditRequestEntity.fromMap(Map<String, dynamic> map) {
    final entity = CreditRequestEntity(
      id: map['id'] ?? '',
      issuerCompanyId: map['issuerCompanyId'] ?? '',
      proyectoId: '',
      creditAmount: (map['creditAmount'] as num?)?.toDouble() ?? 0.0,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.draft,
      ),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseDate(map['updatedAt']) : null,
      submittedAt: map['submittedAt'] != null ? _parseDate(map['submittedAt']) : null,
      project: map['project'] != null
          ? WaterProjectEntity.fromMap(map['project'] as Map<String, dynamic>)
          : null,
    );
    if (map['documents'] != null) {
      entity.documents = (map['documents'] as List<dynamic>)
          .map((d) => DocumentEntity.fromMap(d as Map<String, dynamic>))
          .toList();
    }
    if (map['roadmap'] != null) {
      entity.roadmap = RoadmapEntity.fromMap(map['roadmap'] as Map<String, dynamic>);
    }
    return entity;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

