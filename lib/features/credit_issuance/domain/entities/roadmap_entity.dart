import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';

class RoadmapEntity {
  List<PhaseEntity> phases;

  RoadmapEntity({
    required this.phases,
  });

  Map<String, dynamic> toMap() => {
    'phases': phases.map((p) => p.toMap()).toList(),
  };

  factory RoadmapEntity.fromMap(Map<String, dynamic> map) => RoadmapEntity(
    phases: (map['phases'] as List<dynamic>? ?? [])
        .map((p) => PhaseEntity.fromMap(p as Map<String, dynamic>))
        .toList(),
  );
}

