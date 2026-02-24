import 'dart:ui';

class TextColor {
  final Color color;

  final String label;

  const TextColor({required this.color, required this.label});
}

class Settings {
  static const textColor = [
    TextColor(color: Color(0xfff03f24), label: "胭脂红"),
    TextColor(color: Color(0xfff0945d), label: "海螺橙"),
    TextColor(color: Color(0xffdc9123), label: "风帆黄"),
    TextColor(color: Color(0xffbacf65), label: "苹果绿"),
    TextColor(color: Color(0xff158bb8), label: "鸢尾蓝"),
    TextColor(color: Color(0xff1661ab), label: "靛青"),
    TextColor(color: Color(0xff61649f), label: "山梗紫"),
  ];
}
