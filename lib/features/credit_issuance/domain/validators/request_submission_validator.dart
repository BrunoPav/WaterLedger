import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/document_validator.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/water_project_validator.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/roadmap_validator.dart';


class RequestSubmissionValidator {
  static List<String> validate({
    required CreditRequestEntity request,
    required WaterProjectEntity project,
    required RoadmapEntity roadmap,
    required List<DocumentEntity> documents,
  }) {
    final errors = <String>[];

    errors.addAll(WaterProjectValidator.validate(project));
    errors.addAll(RoadmapValidator.validate(roadmap));
    errors.addAll(DocumentValidator.validate(documents));

    if (request.creditAmount <= 0) {
      errors.add('La cantidad de créditos debe ser mayor a cero.');
    }

    return errors;
  }
}