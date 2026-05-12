import 'package:water_ledger/features/credit_issuance/domain/entities/sustainability_goal_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

class CreditRequestEntity {
  String id;
  String issuerCompanyId;
  String proyectoId;
  double creditAmount;
  RequestStatus status;
  SustainabilityGoalEntity sustainabilityGoal;
  DateTime createdAt;
  DateTime? updatedAt;

  CreditRequestEntity({
    required this.id,
    required this.issuerCompanyId,
    required this.proyectoId,
    required this.creditAmount,
    this.status = RequestStatus.pending,
    required this.sustainabilityGoal,
    required this.createdAt,
    this.updatedAt,
  });
}

