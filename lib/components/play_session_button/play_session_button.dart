import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:IceyPlayer/components/bottom_sheet/bottom_sheet.dart';
import 'package:IceyPlayer/components/list_card/list_card.dart';
import 'package:IceyPlayer/components/list_item/list_item.dart';
import 'package:IceyPlayer/components/round_icon_button/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_flutter/signals_core.dart';

part './controller.dart';

part 'state.dart';

class PlaySessionButton extends StatefulWidget {
  final double size;
  final Color? color;

  const PlaySessionButton({super.key, this.size = 24.0, this.color});

  @override
  State<PlaySessionButton> createState() => _PlaySessionButtonState();
}

class _PlaySessionButtonState extends State<PlaySessionButton> {
  final controller = PlaySessionButonController();

  Future<void> handleTap(BuildContext context) async {
    final theme = Theme.of(context);

    scrollableBottomSheet(
      context: context,
      builder: (context) {
        final devices = controller.state.devices.watch(context);

        final currentDevice = controller.state.currentDevice.watch(context);

        return [
          Text("Icey妙播", style: theme.textTheme.titleMedium),
          ListCard(
            spacing: 16.h,
            children: devices.map((device) {
              final item = AudioDeviceTypeText.getByValue(device.type);

              return ListItem(
                // active: currentDevice?.id == device.id,
                icon: Icon(item.icon, size: 24.sp),
                title: device.name,
                desc: item.name,
                trailing: const SizedBox(),
                onTap: () => controller._switchToDevice(device.type),
              );
            }).toList(),
          ),
        ];
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? Theme.of(context).colorScheme.onSurface;

    return RoundIconButton(
      color: iconColor,
      size: widget.size * 2.1,
      icon: SFIcon(SFIcons.sf_airplay_audio, fontSize: widget.size),
      onTap: () => handleTap(context),
    );
  }
}
