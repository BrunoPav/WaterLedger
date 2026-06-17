import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/roadmap_validator.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/water_project_validator.dart';

class RequestSubmissionValidator {
  static List<String> validate({
    required CreditRequestEntity request,
    WaterProjectEntity? project,
    RoadmapEntity? roadmap,
  }) {
    final errors = <String>[];

    if (project == null) {
      errors.add('Falta información del proyecto (completá el paso 2).');
    } else {
      errors.addAll(WaterProjectValidator.validate(project));
    }

    if (roadmap == null) {
      errors.add('Debe completar el roadmap (completá el paso 4).');
    } else {
      errors.addAll(RoadmapValidator.validate(roadmap));
    }

    if (request.creditAmount <= 0) {
      errors.add('La cantidad de créditos debe ser mayor a cero.');
    }

    return errors;
  }
}
