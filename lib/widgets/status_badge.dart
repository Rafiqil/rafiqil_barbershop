import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge status berwarna serbaguna.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  factory StatusBadge.success(String label, {IconData? icon}) => StatusBadge(
        label: label,
        color: AppColors.success,
        background: AppColors.successSoft,
        icon: icon,
      );

  factory StatusBadge.warning(String label, {IconData? icon}) => StatusBadge(
        label: label,
        color: AppColors.warning,
        background: AppColors.warningSoft,
        icon: icon,
      );

  factory StatusBadge.danger(String label, {IconData? icon}) => StatusBadge(
        label: label,
        color: AppColors.danger,
        background: AppColors.dangerSoft,
        icon: icon,
      );

  factory StatusBadge.info(String label, {IconData? icon}) => StatusBadge(
        label: label,
        color: AppColors.info,
        background: AppColors.infoSoft,
        icon: icon,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
