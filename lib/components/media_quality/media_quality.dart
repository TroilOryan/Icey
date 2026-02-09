import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class MediaQuality extends StatelessWidget {
  final String? quality;

  const MediaQuality({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Builder(
        builder: (context) {
          if (quality == "HR") {
            return ExtendedImage.asset(
              'assets/images/hr.png',
              height: 12,
              gaplessPlayback: true,
            );
          } else if (quality == "HQ") {
            return ExtendedImage.asset(
              'assets/images/hq.png',
              height: 12,
              gaplessPlayback: true,
            );
          } else if (quality == "SQ") {
            return ExtendedImage.asset(
              'assets/images/hq.png',
              height: 12,
              gaplessPlayback: true,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
