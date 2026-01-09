import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Widget child;
  final bool disabled;
  final bool block;
  final VoidCallback onPressed;

  const Button(
      {super.key,
      required this.child,
      this.disabled = false,
      this.block = false,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final button =
        FilledButton(onPressed: disabled ? null : onPressed, child: child);

    if (block) {
      return Row(
        children: [Expanded(child: button)],
      );
    }

    return button;
  }
}
