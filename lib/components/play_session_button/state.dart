part of 'play_session_button.dart';

class PlaySessionButtonState {
  final devices = signal<List<AudioDevice>>([]);

  final currentDevice = signal<AudioDevice?>(null);
}
