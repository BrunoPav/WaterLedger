import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Item de lista de "Recent Activity" reusable.
class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timestamp;
  final bool isLast;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.15),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DashboardTokens.surfaceContainerColor,
            ),
            child: Icon(icon, size: 18, color: DashboardTokens.onSurfaceVariantColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardTokens.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: DashboardTokens.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timestamp,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: DashboardTokens.onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state honesto para cuando todavía no hay actividad cargada.
class ActivityEmptyState extends StatelessWidget {
  final String message;

  const ActivityEmptyState({
    super.key,
    this.message = 'Todavía no hay actividad.',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            size: 32,
            color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
