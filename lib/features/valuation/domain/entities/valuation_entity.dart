import 'package:water_ledger/features/valuation/domain/enums/valuation_status.dart';

class ValuationEntity {
  final String requestId;
  final String adminId;
  final ValuationStatus status;
  final double assessedValue;
  final double pricePerCredit;
  final String methodology;
  final String notes;
  final DateTime? appraisedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ValuationEntity({
    required this.requestId,
    required this.adminId,
    required this.status,
    required this.assessedValue,
    required this.pricePerCredit,
    required this.methodology,
    required this.notes,
    this.appraisedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'adminId': adminId,
        'status': status.name,
        'assessedValue': assessedValue,
        'pricePerCredit': pricePerCredit,
        'methodology': methodology,
        'notes': notes,
        if (appraisedAt != null) 'appraisedAt': appraisedAt!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ValuationEntity.fromMap(Map<String, dynamic> map) => ValuationEntity(
        requestId: map['requestId'] as String,
        adminId: map['adminId'] as String,
        status: ValuationStatus.fromString(map['status'] as String? ?? 'rejected'),
        assessedValue: (map['assessedValue'] as num?)?.toDouble() ?? 0.0,
        pricePerCredit: (map['pricePerCredit'] as num?)?.toDouble() ?? 0.0,
        methodology: map['methodology'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        appraisedAt: map['appraisedAt'] != null
            ? (map['appraisedAt'] is DateTime
                ? map['appraisedAt'] as DateTime
                : DateTime.parse(map['appraisedAt'] as String))
            : null,
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] is DateTime
            ? map['updatedAt'] as DateTime
            : DateTime.parse(map['updatedAt'] as String),
      );
}
