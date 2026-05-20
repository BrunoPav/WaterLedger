import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

class CreditRequestEntity {
  String id;
  String issuerCompanyId;
  String proyectoId;
  double creditAmount;
  RequestStatus status;
  List<DocumentEntity> documents = [];
  RoadmapEntity? roadmap;
  DateTime createdAt;
  DateTime? updatedAt;

  CreditRequestEntity({
    required this.id,
    required this.issuerCompanyId,
    required this.proyectoId,
    required this.creditAmount,
    this.status = RequestStatus.draft,
    required this.createdAt,
    this.updatedAt,
  });
}

