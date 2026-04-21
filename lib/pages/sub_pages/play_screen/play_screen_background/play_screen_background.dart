import 'package:IceyPlayer/models/media/media.dart';
import 'package:blur/blur.dart';
import 'package:IceyPlayer/components/play_cover/play_cover.dart';
import 'package:IceyPlayer/models/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
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

    // 为每个分割部分创建独立的动画控制器
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

        final blurValue = computed(() => highMaterial ? 84.0 : 24.0);

        final colorOpacity = computed(() => artCover ? 0.01 : 0.5);

        final cover = PlayCover(
          height: height,
          width: width,
          repeat: ImageRepeat.repeat,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.low,
        );

        return FrameSeparateWidget(
          child: Blur(
            blur: blurValue(),
            colorOpacity: colorOpacity(),
            overlay: null,
            child: Stack(
              children: [
                RepaintBoundary(child: cover),
                if (dynamicLight) ...[
                  _buildAnimatedCover(
                    cover,
                    TopLeftClipper(),
                    _controller1,
                    0.8,
                  ),
                  _buildAnimatedCover(
                    cover,
                    TopRightClipper(),
                    _controller2,
                    -0.8,
                  ),
                  _buildAnimatedCover(
                    cover,
                    BottomLeftClipper(),
                    _controller3,
                    -1,
                  ),
                  _buildAnimatedCover(
                    cover,
                    BottomRightClipper(),
                    _controller4,
                    1,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCover(
    Widget cover,
    CustomClipper<Rect> clipper,
    AnimationController controller,
    double rotationRange,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: -rotationRange,
        end: rotationRange,
      ).animate(controller),
      child: ClipRect(clipper: clipper, child: cover),
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
