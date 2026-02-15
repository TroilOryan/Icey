import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final Color? color;
  final Widget icon;
  final double size;
  final double iconSize;
  final bool ghost;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const RoundIconButton({
    super.key,
    this.color,
    this.size = 36,
    this.iconSize = 16,
    required this.icon,
    required this.onTap,
    this.ghost = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: ghost ? Colors.transparent : theme.appBarTheme.backgroundColor,
      elevation: ghost ? 0 : 3,
      shadowColor: theme.textTheme.titleLarge!.color!.withAlpha(55),
      shape: const CircleBorder(),
      child: Ink(
        width: size,
        height: size,
        child: IconButton(
          color: color,
          iconSize: iconSize,
          icon: icon,
          onPressed: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
