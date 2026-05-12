import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';

class RoadmapValidator {
  static List<String> validate(RoadmapEntity roadmap) {
    final errors = <String>[];

    if (roadmap.phases.isEmpty) {
      errors.add('Debe existir al menos una fase en la hoja de ruta.');
    }

    for (final phase in roadmap.phases) {
      if (phase.startDate.isAfter(phase.endDate)) {
        errors.add('La fase ${phase.name} tiene fechas inválidas.');
      }

      if (phase.milestones.isEmpty) {
        errors.add('La fase ${phase.name} debe incluir hitos.');
      }
    }

    return errors;
  }
}