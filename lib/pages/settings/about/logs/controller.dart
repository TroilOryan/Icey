part of 'page.dart';

class LogsController {
  final state = LogsState();

  Future<void> getLog() async {
    final logsPath = await LogsHelper.getLogsPath();
    state.logs.value = (await logsPath.readAsLines()).reversed.map((i) {
      try {
        final log = Report.fromJson(jsonDecode(i));
        state.latestLog.value ??= log.copyWith();
        return log;
      } catch (e, s) {
        return Report(
          'Parse log failed: $e\n\n\n$i',
          s,
          DateTime.now(),
          const {},
          const {},
          const {},
          null,
          PlatformType.unknown,
          null,
        );
      }
    }).toList();
  }

  void showInfo(String title, Map<String, dynamic> map, BuildContext context) {
    final theme = Theme.of(context);

    scrollableBottomSheet(
      context: context,
      builder: (context) => [
        Text(title, style: theme.textTheme.titleMedium),
        ListCard(
          children: map.entries
              .map(
                (entry) =>
                    ListItem(title: entry.key, desc: entry.value.toString()),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> clearLogs() async {
    if (await LogsHelper.clearLogs()) {
      showToast("已清空");
      state.logs.value = [];
    }
  }

  void onInit() {
    getLog();
  }

  void onDispose() {
    if (state.latestLog.value != null) {
      final time = state.latestLog.value!.dateTime;
      if (DateTime.now().difference(time) >= const Duration(days: 14)) {
        LogsHelper.clearLogs();
      }
    }
  }
}
