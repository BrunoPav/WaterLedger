enum InsurancePlanType {
  basic,
  standard,
  premium;

  String get label => switch (this) {
        basic => 'Básico',
        standard => 'Estándar',
        premium => 'Premium',
      };

  static InsurancePlanType fromString(String value) => switch (value) {
        'basic' => basic,
        'premium' => premium,
        _ => standard,
      };
}
