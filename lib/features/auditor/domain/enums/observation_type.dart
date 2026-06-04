enum ObservationType {
  general,
  technical,
  environmental,
  financial;

  String get label => switch (this) {
        ObservationType.general => 'General',
        ObservationType.technical => 'Técnica',
        ObservationType.environmental => 'Ambiental',
        ObservationType.financial => 'Financiera',
      };

  static ObservationType fromString(String value) =>
      ObservationType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ObservationType.general,
      );
}
