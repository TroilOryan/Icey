import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class PlayLyricButton extends StatelessWidget {
  final double size;
  final bool? active;
  final Color? color;
  final VoidCallback onTap;

  const PlayLyricButton({
    super.key,
    this.size = 24.0,
    this.active = false,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      color: iconColor,
      size: size * 2.1,
      icon: AnimatedSwitcher(
        duration: AppTheme.defaultDuration,
        child: SFIcon(
          key: ValueKey(active),
          active == true
              ? SFIcons.sf_quote_bubble_fill
              : SFIcons.sf_quote_bubble,
          fontSize: size,
        ),
      ),
      onTap: onTap,
    );
  }
}
