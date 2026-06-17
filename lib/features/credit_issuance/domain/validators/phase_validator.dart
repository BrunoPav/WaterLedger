import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/shared/domain/validators/field_rules.dart';

class PhaseValidator {
  static List<String> validate(PhaseEntity phase) {
    final errors = <String>[];

    void addIfError(String? Function(String?) rule, String value) {
      final error = rule(value);
      if (error != null) errors.add(error);
    }

    addIfError(
      FieldRules.compose([
        FieldRules.required('El nombre de la fase es obligatorio.'),
        FieldRules.minLength(
          FieldLimits.phaseNameMin,
          message: 'El nombre de la fase debe tener al menos ${FieldLimits.phaseNameMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.phaseNameMax,
          message: 'El nombre de la fase no puede superar los ${FieldLimits.phaseNameMax} caracteres.',
        ),
        FieldRules.mustContainLetters(
          message: 'El nombre de la fase no puede ser solo números o símbolos.',
        ),
      ]),
      phase.name,
    );

    if (!phase.endDate.isAfter(phase.startDate)) {
      errors.add('La fase "${phase.name}" debe tener una fecha de fin posterior a la de inicio.');
    }

    if (phase.milestones.isEmpty) {
      errors.add('La fase "${phase.name}" debe incluir al menos un hito.');
    }

    return errors;
  }
}
