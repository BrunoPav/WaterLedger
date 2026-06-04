import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Header de sección con título + opcional "View all" CTA.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.primaryColor,
              letterSpacing: -0.2,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.secondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
