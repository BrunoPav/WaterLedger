import 'package:flutter/material.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

Color requestStatusColor(RequestStatus status) => switch (status) {
      RequestStatus.draft => const Color(0xFF9E9E9E),
      RequestStatus.pending => const Color(0xFFFF8F00),
      RequestStatus.underAudit => const Color(0xFF1565C0),
      RequestStatus.certified => const Color(0xFF2E7D32),
      RequestStatus.insured => const Color(0xFF00695C),
      RequestStatus.valued => const Color(0xFF6A1B9A),
      RequestStatus.published => const Color(0xFF1B5E20),
      RequestStatus.rejected => const Color(0xFFC62828),
    };
