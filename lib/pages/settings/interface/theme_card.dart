import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class ThemeCard extends StatelessWidget {
  final String activeValue;
  final String value;
  final Function(String) onTap;

  const ThemeCard({
    super.key,
    required this.activeValue,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightnessTheme = BrightnessTheme.getByValue(value);
    final active = activeValue == value;

    return Flexible(
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(AppTheme.borderRadiusSm),
        color: active
            ? theme.colorScheme.secondary.withAlpha(AppTheme.defaultAlphaLight)
            : theme.scaffoldBackgroundColor,
        child: Ink(
          child: InkWell(
            onTap: () => onTap(value),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  SFIcon(
                    active ? brightnessTheme.activeIcon : brightnessTheme.icon,
                    fontSize: 18,
                  ),
                  Text(brightnessTheme.name),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
