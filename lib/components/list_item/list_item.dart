import 'package:IceyPlayer/components/icey_switch/icey_switch.dart';
import 'package:IceyPlayer/models/pro/pro.dart';
import 'package:IceyPlayer/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:signals/signals_flutter.dart';

class ListItem extends StatelessWidget {
  final bool active;
  final String title;
  final Widget? icon;
  final String? desc;
  final bool isSwitch;
  final bool isMultiSwitch;
  final dynamic value;
  final List<String>? values;
  final bool disabled;
  final bool isPro;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged;
  final ValueChanged<String>? onMultiChanged;

  const ListItem({
    super.key,
    this.active = false,
    required this.title,
    this.icon,
    this.desc,
    this.isSwitch = false,
    this.isMultiSwitch = false,
    this.value = false,
    this.values,
    this.disabled = false,
    this.isPro = false,
    this.trailing,
    this.onTap,
    this.onChanged,
    this.onMultiChanged,
  });

  void handleTap(bool disabled) {
    if (onTap == null && onChanged != null && !disabled) {
      onChanged!(!value);
    } else if (onTap == null && onMultiChanged != null && !disabled) {
      // onMultiChanged!(value);
    } else if (onTap != null && !disabled) {
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = proManager.enabled.watch(context);

    final theme = Theme.of(context);

    final titleChildren = [];

    final children = [];

    if (icon != null) {
      titleChildren.add(icon);
    }

    final _disabled = disabled == true || (isPro && !enabled);

    if (isSwitch) {
      children.add(
        IceySwitch(value: value, disabled: _disabled, onChanged: onChanged),
      );
    }

    if (isMultiSwitch && values != null) {
      // children.add(MultiSwitch());
      children.add(
        PopupMenuButton<String>(
          clipBehavior: Clip.antiAlias,
          splashRadius: 0,
          child: Text(value, style: theme.textTheme.bodyLarge),
          itemBuilder: (context) => values!
              .map((value) => PopupMenuItem(value: value, child: Text(value)))
              .toList(),
          onSelected: (value) {
            if (onMultiChanged != null) {
              onMultiChanged!(value);
            }
          },
        ),
      );
    }

    if (trailing != null) {
      children.add(trailing);
    }

    if (onTap != null && !_disabled && trailing == null) {
      children.add(const Icon(Icons.chevron_right));
    }

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
      child: InkWell(
        onTap: () => handleTap(_disabled),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  spacing: 16,
                  children: [
                    ...titleChildren,
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: isPro == true ? 16 : 0,
                            children: [
                              isPro == true
                                  ? const Icon(
                                      SFIcons.sf_crown_fill,
                                      color: Colors.amber,
                                    )
                                  : const SizedBox(),
                              Flexible(
                                child: Text(
                                  title,
                                  style: theme.listTileTheme.titleTextStyle
                                      ?.copyWith(
                                        color: active
                                            ? theme.colorScheme.primary
                                            : null,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          desc != null
                              ? Text(
                                  desc!,
                                  style: theme.listTileTheme.subtitleTextStyle,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
