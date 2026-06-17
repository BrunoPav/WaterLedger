import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/shared/domain/validators/field_rules.dart';

class WaterProjectValidator {
  static List<String> validate(WaterProjectEntity project) {
    final errors = <String>[];

    void addIfError(String? Function(String?) rule, String value) {
      final error = rule(value);
      if (error != null) errors.add(error);
    }

    addIfError(
      FieldRules.compose([
        FieldRules.required('El nombre del proyecto es obligatorio.'),
        FieldRules.minLength(
          FieldLimits.nameMin,
          message: 'El nombre del proyecto debe tener al menos ${FieldLimits.nameMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.nameMax,
          message: 'El nombre del proyecto no puede superar los ${FieldLimits.nameMax} caracteres.',
        ),
        FieldRules.mustContainLetters(
          message: 'El nombre del proyecto no puede ser solo números o símbolos.',
        ),
      ]),
      project.name,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('La ubicación del proyecto es obligatoria.'),
        FieldRules.minLength(
          FieldLimits.locationMin,
          message: 'La ubicación debe tener al menos ${FieldLimits.locationMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.locationMax,
          message: 'La ubicación no puede superar los ${FieldLimits.locationMax} caracteres.',
        ),
      ]),
      project.location,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('El resumen del proyecto es obligatorio.'),
        FieldRules.minLength(
          FieldLimits.summaryMin,
          message: 'El resumen debe tener al menos ${FieldLimits.summaryMin} caracteres para ser descriptivo.',
        ),
        FieldRules.maxLength(
          FieldLimits.summaryMax,
          message: 'El resumen no puede superar los ${FieldLimits.summaryMax} caracteres.',
        ),
      ]),
      project.summary,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('Debe especificarse el impacto hídrico esperado.'),
        FieldRules.minLength(
          FieldLimits.impactMin,
          message: 'Describí el impacto hídrico esperado con al menos ${FieldLimits.impactMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.impactMax,
          message: 'El impacto hídrico esperado no puede superar los ${FieldLimits.impactMax} caracteres.',
        ),
      ]),
      project.expectedWaterImpact,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('El objetivo de sostenibilidad es obligatorio.'),
        FieldRules.minLength(
          FieldLimits.objectiveMin,
          message: 'El objetivo de sostenibilidad debe tener al menos ${FieldLimits.objectiveMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.objectiveMax,
          message: 'El objetivo de sostenibilidad no puede superar los ${FieldLimits.objectiveMax} caracteres.',
        ),
      ]),
      project.sustainabilityGoal.objective,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('La descripción del objetivo de sostenibilidad es obligatoria.'),
        FieldRules.minLength(
          FieldLimits.goalDescMin,
          message: 'La descripción del objetivo debe tener al menos ${FieldLimits.goalDescMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.goalDescMax,
          message: 'La descripción del objetivo no puede superar los ${FieldLimits.goalDescMax} caracteres.',
        ),
      ]),
      project.sustainabilityGoal.description,
    );

    addIfError(
      FieldRules.compose([
        FieldRules.required('Debe especificarse el entorno ambiental beneficiado.'),
        FieldRules.minLength(
          FieldLimits.environmentMin,
          message: 'El entorno beneficiado debe tener al menos ${FieldLimits.environmentMin} caracteres.',
        ),
        FieldRules.maxLength(
          FieldLimits.environmentMax,
          message: 'El entorno beneficiado no puede superar los ${FieldLimits.environmentMax} caracteres.',
        ),
      ]),
      project.sustainabilityGoal.benefittedEnvironment,
    );

    addIfError(
      FieldRules.positiveAmount(
        min: 1,
        max: FieldLimits.maxInvestmentUsd,
        requiredMessage: 'La inversión estimada es obligatoria.',
        invalidMessage: 'La inversión estimada debe ser un valor numérico válido.',
        belowMinMessage: 'La inversión estimada debe ser mayor a cero.',
        aboveMaxMessage: 'La inversión estimada supera el máximo permitido (USD ${FieldLimits.maxInvestmentUsd}).',
      ),
      project.estimatedInvestment.toStringAsFixed(0),
    );

    return errors;
  }
}
