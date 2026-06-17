import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/phase_validator.dart';

class RoadmapValidator {
  static List<String> validate(RoadmapEntity roadmap) {
    final errors = <String>[];

    if (roadmap.phases.isEmpty) {
      errors.add('Debe existir al menos una fase en la hoja de ruta.');
    }

    for (final phase in roadmap.phases) {
      errors.addAll(PhaseValidator.validate(phase));
    }

    final seenNames = <String>{};
    for (final phase in roadmap.phases) {
      final key = phase.name.trim().toLowerCase();
      if (key.isEmpty || !seenNames.add(key)) {
        if (key.isNotEmpty) {
          errors.add('Hay más de una fase llamada "${phase.name}". Usá nombres distintos para cada fase.');
        }
      }
    }

    return errors;
  }
}
