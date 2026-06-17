class FieldRules {
  FieldRules._();

  static String? Function(String?) compose(
    List<String? Function(String?)> rules,
  ) {
    return (value) {
      for (final rule in rules) {
        final error = rule(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  static String? Function(String?) required([
    String message = 'Campo requerido.',
  ]) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? Function(String?) minLength(
    int min, {
    required String message,
  }) {
    return (value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return null;
      return v.length < min ? message : null;
    };
  }

  static String? Function(String?) maxLength(
    int max, {
    required String message,
  }) {
    return (value) {
      final v = (value ?? '').trim();
      return v.length > max ? message : null;
    };
  }

  static String? Function(String?) mustContainLetters({
    required String message,
  }) {
    final letterPattern = RegExp(r'[a-zA-ZÁÉÍÓÚáéíóúÑñÜü]');
    return (value) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return null;
      return letterPattern.hasMatch(v) ? null : message;
    };
  }

  static String? Function(String?) positiveAmount({
    required num min,
    required num max,
    String requiredMessage = 'Campo requerido.',
    String invalidMessage = 'Ingresá solo números.',
    required String belowMinMessage,
    required String aboveMaxMessage,
  }) {
    return (value) {
      final raw = (value ?? '').replaceAll(',', '').trim();
      if (raw.isEmpty) return requiredMessage;
      final parsed = num.tryParse(raw);
      if (parsed == null) return invalidMessage;
      if (parsed < min) return belowMinMessage;
      if (parsed > max) return aboveMaxMessage;
      return null;
    };
  }

  static String? Function(String?) decimalAmount({
    required num min,
    required num max,
    String requiredMessage = 'Campo requerido.',
    String invalidMessage = 'Ingresá solo números.',
    required String belowMinMessage,
    required String aboveMaxMessage,
  }) {
    return (value) {
      final raw = (value ?? '').trim().replaceAll(',', '.');
      if (raw.isEmpty) return requiredMessage;
      final parsed = double.tryParse(raw);
      if (parsed == null) return invalidMessage;
      if (parsed < min) return belowMinMessage;
      if (parsed > max) return aboveMaxMessage;
      return null;
    };
  }
}

class FieldLimits {
  FieldLimits._();

  static const nameMin = 3;
  static const nameMax = 120;

  static const locationMin = 3;
  static const locationMax = 150;

  static const summaryMin = 20;
  static const summaryMax = 2000;

  static const impactMin = 10;
  static const impactMax = 1000;

  static const objectiveMin = 5;
  static const objectiveMax = 200;

  static const goalDescMin = 10;
  static const goalDescMax = 2000;

  static const environmentMin = 3;
  static const environmentMax = 200;

  static const phaseNameMin = 3;
  static const phaseNameMax = 100;

  static const maxInvestmentUsd = 1000000000;
  static const maxCreditAmount = 100000000;
}
