enum CertificationStatus {
  issued,
  rejected;

  static CertificationStatus fromString(String value) => switch (value) {
        'issued' => issued,
        _ => rejected,
      };
}
