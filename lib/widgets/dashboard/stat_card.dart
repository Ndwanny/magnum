import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final double? changePercent;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(icon, color: c, size: 22),
                ),
                if (changePercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (changePercent! >= 0 ? AppColors.success : AppColors.error).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          changePercent! >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: changePercent! >= 0 ? AppColors.success : AppColors.error,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${changePercent!.abs()}%',
                          style: TextStyle(
                            color: changePercent! >= 0 ? AppColors.success : AppColors.error,
                            fontSize: 11, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 28,
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
            )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11,
              )),
            ],
          ],
        ),
      ),
    );
  }
}
