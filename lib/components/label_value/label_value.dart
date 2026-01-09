import 'package:flutter/material.dart';

class LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const LabelValue({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(value, style: theme.textTheme.titleSmall),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
