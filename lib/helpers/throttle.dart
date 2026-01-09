import 'dart:async';

class Throttle {
  final Duration duration;
  bool _canCall = true;
  Timer? _timer;

  Throttle(this.duration);

  void call(Function callback) {
    if (!_canCall) {
      // 时间窗口内，忽略调用
      return;
    }

    // 第一次调用，立即执行
    callback();

    _canCall = false;

    // 启动定时器，时间窗口结束后允许下一次调用
    _timer = Timer(duration, () {
      _canCall = true;
      _timer = null;
    });
  }
}
