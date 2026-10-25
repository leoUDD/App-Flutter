import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.fontSize = 14,
    this.ringColor,
  });

  final String initials;
  final double size;
  final double fontSize;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final ring = ringColor;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.avatar,
        border: ring == null ? null : Border.all(color: ring, width: 3),
      ),
      child: Text(
        initials,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}
