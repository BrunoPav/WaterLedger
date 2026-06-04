import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

class ComingSoonBanner extends StatelessWidget {
  const ComingSoonBanner({
    super.key,
    required this.feature,
    this.dependsOn,
  });

  final String feature;
  final String? dependsOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DashboardTokens.secondaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.construction_outlined,
            color: DashboardTokens.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$feature — próximamente',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DashboardTokens.secondaryColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dependsOn != null
                      ? 'Este módulo estará disponible en una versión futura. Requiere: $dependsOn.'
                      : 'Este módulo estará disponible en una versión futura.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: DashboardTokens.secondaryColor.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
