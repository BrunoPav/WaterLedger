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
}