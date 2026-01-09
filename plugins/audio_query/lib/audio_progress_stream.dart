import 'package:flutter/services.dart';

class AudioProgressStream {
  static const EventChannel _eventChannel = EventChannel(
    'audio_query_progress',
  );

  static Stream<Map<String, dynamic>> get progressStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }
}
