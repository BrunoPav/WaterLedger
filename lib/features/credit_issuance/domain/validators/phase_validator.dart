import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';

class PhaseValidator {
  static List<String> validate(PhaseEntity phase) {
    final errors = <String>[];

    if (phase.name.trim().isEmpty) {
      errors.add('El nombre de la fase es obligatorio.');
    }

    if (phase.startDate.isAfter(phase.endDate)) {
      errors.add('La fase ${phase.name} tiene fechas inválidas.');
    }

    if (phase.milestones.isEmpty) {
      errors.add('La fase ${phase.name} debe incluir hitos.');
    }

    return errors;
  }
}