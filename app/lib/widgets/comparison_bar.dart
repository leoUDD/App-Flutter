import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ComparisonBar extends StatelessWidget {
  const ComparisonBar({super.key, required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 9,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: fraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: constraints.maxWidth * progress,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
