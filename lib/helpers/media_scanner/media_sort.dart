/// 媒体排序方式
enum MediaSort {
  title(value: 1, name: "按名称"),
  artist(value: 2, name: "按艺术家"),
  addTime(value: 3, name: "按添加时间"),
  addTimeDesc(value: 4, name: "按添加时间降序"),
  modifyTime(value: 5, name: "按修改时间"),
  modifyTimeDesc(value: 6, name: "按修改时间降序"),
  duration(value: 7, name: "按时长"),
  durationDesc(value: 8, name: "按时长降序"),
  count(value: 9, name: "按播放次数"),
  countDesc(value: 10, name: "按播放次数降序");

  const MediaSort({required this.value, required this.name});

  final int value;
  final String name;

  static MediaSort getByValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}
