import 'package:flutter/material.dart';

class LeadingButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const LeadingButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Ink(
      width: 36,
      height: 36,
      decoration: ShapeDecoration(
        color: theme.secondaryHeaderColor,
        shape: const CircleBorder(),
      ),
      child: IconButton(iconSize: 16, icon: icon, onPressed: onTap),
    );
  }
}
