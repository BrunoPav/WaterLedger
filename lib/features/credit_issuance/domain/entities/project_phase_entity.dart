import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';

class PhaseEntity {
  String name;
  DateTime startDate;
  DateTime endDate;
  List<Milestones> milestones;

  PhaseEntity({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.milestones,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'milestones': milestones.map((m) => m.name).toList(),
  };

  factory PhaseEntity.fromMap(Map<String, dynamic> map) => PhaseEntity(
    name: map['name'] ?? '',
    startDate: _parseDate(map['startDate']),
    endDate: _parseDate(map['endDate']),
    milestones: (map['milestones'] as List<dynamic>? ?? [])
        .map((m) => Milestones.values.firstWhere(
              (e) => e.name == m,
              orElse: () => Milestones.initialAudit,
            ))
        .toList(),
  );

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}