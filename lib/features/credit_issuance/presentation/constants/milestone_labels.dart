import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';

const Map<Milestones, String> milestoneLabels = {
  Milestones.initialAudit: 'Initial Audit',
  Milestones.meterInstalation: 'Meter Installation',
  Milestones.infrastructureValidation: 'Infrastructure Validation',
  Milestones.operativeSistem: 'Operative System',
  Milestones.firstWaterSavingRegistered: 'First Water Saving',
  Milestones.ambientalReportGenerated: 'Environmental Report',
  Milestones.proyectFinalized: 'Project Finalized',
  Milestones.impactVerificated: 'Impact Verified',
  Milestones.proyectReadyToInssue: 'Ready to Issue',
};