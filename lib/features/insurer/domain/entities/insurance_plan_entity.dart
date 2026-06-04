import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_status.dart';
import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_type.dart';

class InsurancePlanEntity {
  final String requestId;
  final String insurerId;
  final InsurancePlanStatus status;
  final InsurancePlanType planType;
  final double coverageAmount;
  final double premiumRate;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InsurancePlanEntity({
    required this.requestId,
    required this.insurerId,
    required this.status,
    required this.planType,
    required this.coverageAmount,
    required this.premiumRate,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'insurerId': insurerId,
        'status': status.name,
        'planType': planType.name,
        'coverageAmount': coverageAmount,
        'premiumRate': premiumRate,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory InsurancePlanEntity.fromMap(Map<String, dynamic> map) =>
      InsurancePlanEntity(
        requestId: map['requestId'] as String,
        insurerId: map['insurerId'] as String,
        status: InsurancePlanStatus.fromString(map['status'] as String? ?? 'rejected'),
        planType: InsurancePlanType.fromString(map['planType'] as String? ?? 'standard'),
        coverageAmount: (map['coverageAmount'] as num?)?.toDouble() ?? 0.0,
        premiumRate: (map['premiumRate'] as num?)?.toDouble() ?? 0.0,
        notes: map['notes'] as String? ?? '',
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt'] as DateTime
            : DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] is DateTime
            ? map['updatedAt'] as DateTime
            : DateTime.parse(map['updatedAt'] as String),
      );
}
