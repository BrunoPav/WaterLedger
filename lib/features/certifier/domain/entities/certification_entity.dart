import 'package:water_ledger/features/certifier/domain/enums/certification_status.dart';

class CertificationEntity {
  final String requestId;
  final String certifierId;
  final CertificationStatus status;
  final String notes;
  final DateTime? issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CertificationEntity({
    required this.requestId,
    required this.certifierId,
    required this.status,
    required this.notes,
    this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'certifierId': certifierId,
        'status': status.name,
        'notes': notes,
        if (issuedAt != null) 'issuedAt': issuedAt!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CertificationEntity.fromMap(Map<String, dynamic> map) =>
      CertificationEntity(
        requestId: map['requestId'] as String,
        certifierId: map['certifierId'] as String,
        status: CertificationStatus.fromString(map['status'] as String? ?? 'rejected'),
        notes: map['notes'] as String? ?? '',
        issuedAt: map['issuedAt'] != null
            ? (map['issuedAt'] is DateTime
                ? map['issuedAt'] as DateTime
                : DateTime.parse(map['issuedAt'] as String))
            : null,
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] is DateTime
            ? map['updatedAt'] as DateTime
            : DateTime.parse(map['updatedAt'] as String),
      );
}
