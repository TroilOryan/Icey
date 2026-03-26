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
        _buildValue(theme.textTheme.titleSmall),
        _buildLabel(theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildValue(TextStyle? style) {
    return Text(value, style: style);
  }

  Widget _buildLabel(TextStyle? style) {
    return Text(label, style: style);
  }
}
