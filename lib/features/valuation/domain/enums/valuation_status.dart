enum ValuationStatus {
  appraised,
  rejected;

  static ValuationStatus fromString(String value) => switch (value) {
        'appraised' => appraised,
        'rejected' => rejected,
        _ => rejected,
      };
}
