enum InsurancePlanStatus {
  active,
  rejected;

  static InsurancePlanStatus fromString(String value) => switch (value) {
        'active' => active,
        _ => rejected,
      };
}
