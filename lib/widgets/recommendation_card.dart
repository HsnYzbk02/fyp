import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  Color get _priorityColor {
    switch (recommendation['priority']) {
      case 'high':
        return AppTheme.recoveryLow;
      case 'medium':
        return AppTheme.recoveryMid;
      default:
        return AppTheme.accentGreen;
    }
  }

  IconData get _categoryIcon {
    switch (recommendation['category']) {
      case 'Sleep':
        return CupertinoIcons.moon_stars_fill;
      case 'Hydration':
        return CupertinoIcons.drop_fill;
      case 'Nutrition':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'Stretching':
        return CupertinoIcons.person_crop_circle;
      case 'Active Recovery':
        return CupertinoIcons.heart_fill;
      case 'Rest':
        return CupertinoIcons.zzz;
      case 'Training':
        return CupertinoIcons.flame_fill;
      default:
        return CupertinoIcons.star_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duration = recommendation['duration_minutes'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _priorityColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_categoryIcon, color: _priorityColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommendation['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (duration > 0)
                      Text(
                        '${duration}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['description'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
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
