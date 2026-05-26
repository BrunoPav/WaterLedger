import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

class DashboardNavItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const DashboardNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// BottomNavBar glassmorphism con N items configurables.
/// Cada dashboard pasa sus propios items según el rol.
class DashboardBottomNav extends StatelessWidget {
  final List<DashboardNavItem> items;
  final int selectedIndex;

  const DashboardBottomNav({
    super.key,
    required this.items,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: DashboardTokens.bgColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.25),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  return _NavItemWidget(
                    item: items[i],
                    selected: i == selectedIndex,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final DashboardNavItem item;
  final bool selected;

  const _NavItemWidget({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? DashboardTokens.secondaryColor
        : DashboardTokens.onSurfaceVariantColor;

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? DashboardTokens.cyanColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
