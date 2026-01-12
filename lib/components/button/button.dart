import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Widget child;
  final bool disabled;
  final bool primary;
  final bool block;
  final VoidCallback onPressed;

  const Button({
    super.key,
    required this.child,
    this.disabled = false,
    this.primary = true,
    this.block = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: primary ? colorScheme.primary : theme.cardTheme.color,
        foregroundColor: primary
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
      ),
      onPressed: disabled ? null : onPressed,
      child: child,
    );

    if (block) {
      return Row(children: [Expanded(child: button)]);
    }

    return button;
  }
}
