import 'package:IceyPlayer/helpers/logs/logs.dart';
import 'package:signals/signals.dart';

class LogsState {
  final latestLog = signal<Report?>(null);

  final logs = signal<List<Report>>([]);
}
