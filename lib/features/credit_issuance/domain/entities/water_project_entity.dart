import 'package:water_ledger/features/credit_issuance/domain/entities/sustainability_goal_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/project_category.dart';

class WaterProjectEntity {
  String id;
  String name;
  String location;
  ProjectCategory category;
  String summary;
  double estimatedInvestment;
  String expectedWaterImpact;
  SustainabilityGoalEntity sustainabilityGoal;

  WaterProjectEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.summary,
    required this.estimatedInvestment,
    required this.expectedWaterImpact,
    required this.sustainabilityGoal,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'location': location,
    'category': category.name,
    'summary': summary,
    'estimatedInvestment': estimatedInvestment,
    'expectedWaterImpact': expectedWaterImpact,
    'sustainabilityGoal': sustainabilityGoal.toMap(),
  };

  factory WaterProjectEntity.fromMap(Map<String, dynamic> map) =>
      WaterProjectEntity(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        location: map['location'] ?? '',
        category: ProjectCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => ProjectCategory.infrastructure,
        ),
        summary: map['summary'] ?? '',
        estimatedInvestment: (map['estimatedInvestment'] as num?)?.toDouble() ?? 0.0,
        expectedWaterImpact: map['expectedWaterImpact'] ?? '',
        sustainabilityGoal: SustainabilityGoalEntity.fromMap(
          (map['sustainabilityGoal'] as Map<String, dynamic>?) ?? {},
        ),
      );
}