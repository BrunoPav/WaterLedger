import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';

class WaterProjectValidator {
  static List<String> validate(WaterProjectEntity project) {
    final errors = <String>[];

    if (project.name.trim().isEmpty) {
      errors.add('El nombre del proyecto es obligatorio.');
    }

    if (project.location.trim().isEmpty) {
      errors.add('La ubicación del proyecto es obligatoria.');
    }

    if (project.sustainabilityGoal.description.trim().isEmpty) {
      errors.add(
        'La descripción del objetivo de sostenibilidad es obligatoria.',
      );
    }

    if (project.summary.trim().isEmpty) {
      errors.add('El resumen del proyecto es obligatorio.');
    }

    if (project.estimatedInvestment <= 0) {
      errors.add('La inversión estimada debe ser mayor a cero.');
    }

    if (project.expectedWaterImpact.trim().isEmpty) {
      errors.add('Debe especificarse el impacto hídrico esperado.');
    }

    return errors;
  }
}
