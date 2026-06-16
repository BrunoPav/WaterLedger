import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Card de métrica para los dashboards.
/// Soporta 3 estados: data (con value), loading (spinner) o empty (placeholder).
class StatCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final Widget? footer;
  final VoidCallback? onMoreTap;

  const StatCard({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.iconColor = DashboardTokens.onPrimaryContainerColor,
    this.isLoading = false,
    this.footer,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DashboardTokens.onSurfaceVariantColor,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              onMoreTap != null
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onMoreTap,
                        child: const Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: DashboardTokens.onSurfaceVariantColor,
                        ),
                      ),
                    )
                  : Icon(icon, size: 20, color: iconColor),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DashboardTokens.secondaryColor,
                  ),
                ),
              ),
            )
          else
            Text(
              value ?? '—',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.primaryColor,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Pie opcional de StatCard con barra de progreso y un par label/value.
class StatCardProgressFooter extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double progress; // 0.0 → 1.0

  const StatCardProgressFooter({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DashboardTokens.onSurfaceVariantColor,
              ),
            ),
            Text(
              rightLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DashboardTokens.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            children: [
              Container(
                height: 5,
                color: DashboardTokens.surfaceContainerColor,
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DashboardTokens.primaryContainerColor,
                        DashboardTokens.cyanDimColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pie opcional con label + icono pequeño (estilo "Cycle starts next quarter").
class StatCardCaption extends StatelessWidget {
  final IconData icon;
  final String text;

  const StatCardCaption({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: DashboardTokens.onSurfaceVariantColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DashboardTokens.onSurfaceVariantColor,
            ),
          ),
        ),
      ],
    );
  }
}
