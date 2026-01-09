import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundIconButton extends StatelessWidget {
  final Color? color;
  final Widget icon;
  final double? size;
  final double? iconSize;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const RoundIconButton({
    super.key,
    this.color,
    this.size,
    this.iconSize,
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Ink(
      width: size ?? 36.sp,
      height: size ?? 36.sp,
      decoration: ShapeDecoration(
        color: theme.secondaryHeaderColor,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        color: color,
        iconSize: iconSize ?? 16.sp,
        icon: icon,
        onPressed: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
