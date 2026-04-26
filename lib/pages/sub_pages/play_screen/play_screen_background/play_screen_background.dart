import 'dart:typed_data';

import 'package:IceyPlayer/components/media_default_cover/media_default_cover.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class PlayScreenBackground extends StatefulWidget {
  const PlayScreenBackground({super.key});

  @override
  State<PlayScreenBackground> createState() => _PlayScreenBackgroundState();
}

class _PlayScreenBackgroundState extends State<PlayScreenBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(seconds: 35),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    )..repeat(reverse: true);

    _controller4 = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;

    return Builder(
      builder: (context) {
        final highMaterial = settingsManager.highMaterial.watch(context),
            dynamicLight = settingsManager.dynamicLight.watch(context),
            artCover = settingsManager.artCover.watch(context);

        final currentCover = mediaManager.currentCover.watch(context);

        final blurValue = highMaterial ? 84.0 : 24.0;
        final colorOpacity = artCover ? 0.01 : 0.5;

        return Stack(
          children: [
            // 静态模糊背景 - 直接构建，不经过 FrameSeparateWidget / PlayCover
            RepaintBoundary(
              child: Blur(
                blur: blurValue,
                colorOpacity: colorOpacity,
                overlay: null,
                child: _buildCoverImage(currentCover, width, height),
              ),
            ),
            // 动态光效 - 在模糊层之上，RepaintBoundary 隔离
            if (dynamicLight)
              RepaintBoundary(
                child: Stack(
                  children: [
                    _buildAnimatedCover(
                      TopLeftClipper(),
                      _controller1,
                      0.8,
                      currentCover,
                      width,
                      height,
                    ),
                    _buildAnimatedCover(
                      TopRightClipper(),
                      _controller2,
                      -0.8,
                      currentCover,
                      width,
                      height,
                    ),
                    _buildAnimatedCover(
                      BottomLeftClipper(),
                      _controller3,
                      -1,
                      currentCover,
                      width,
                      height,
                    ),
                    _buildAnimatedCover(
                      BottomRightClipper(),
                      _controller4,
                      1,
                      currentCover,
                      width,
                      height,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCoverImage(Uint8List cover, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: cover.isNotEmpty
          ? ExtendedImage.memory(
              cover,
              width: width,
              height: height,
              fit: BoxFit.fitWidth,
              gaplessPlayback: true,
              repeat: ImageRepeat.repeat,
              filterQuality: FilterQuality.low,
            )
          : MediaDefaultCover(size: Size(width, height), isDarkMode: false),
    );
  }

  Widget _buildAnimatedCover(
    CustomClipper<Rect> clipper,
    AnimationController controller,
    double rotationRange,
    Uint8List cover,
    double width,
    double height,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: -rotationRange,
        end: rotationRange,
      ).animate(controller),
      child: ClipRect(
        clipper: clipper,
        child: _buildCoverImage(cover, width, height),
      ),
    );
  }
}

class TopLeftClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class TopRightClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class BottomLeftClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, size.height / 2, size.width / 2, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class BottomRightClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      size.width / 2,
      size.height / 2,
      size.width / 2,
      size.height / 2,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
