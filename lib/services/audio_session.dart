import 'package:IceyPlayer/helpers/platform.dart';
import 'package:audio_session/audio_session.dart';
import 'package:IceyPlayer/models/media/media.dart';

class AudioSessionHandler {
  late AudioSession session;
  final bool _playInterrupted = false;

  Future<bool> setActive(bool active) async {
    if (PlatformHelper.isDesktop) return false;

    return await session.setActive(active);
  }

  AudioSessionHandler() {
    if (PlatformHelper.isDesktop) return;

    initSession();
  }

  Future<void> initSession() async {
    session = await AudioSession.instance;

    session.configure(
      const AudioSessionConfiguration.music().copyWith(
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
      ),
    );

    // 耳机拔出暂停
    session.becomingNoisyEventStream.listen((_) {
      mediaManager.pause();
    });

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        mediaManager.pause();
      }

      // session.interruptionEventStream.listen((event) {
      //   final isPlaying = mediaManager.isPlaying;
      //
      //   if (event.begin) {
      //     if (!settingsManager.audioFocus.value &&
      //         event.type == AudioInterruptionType.pause) {
      //       mediaManager.play();
      //     }
      //
      //     switch (event.type) {
      //       case AudioInterruptionType.duck:
      //         // player.setVolume(player.volume.value * 0.5);
      //         break;
      //       case AudioInterruptionType.pause:
      //         // player.pause(isInterrupt: true);
      //         _playInterrupted = true;
      //         break;
      //       case AudioInterruptionType.unknown:
      //         _playInterrupted = true;
      //         break;
      //     }
      //   } else {
      //     switch (event.type) {
      //       case AudioInterruptionType.duck:
      //         // player.setVolume(player.volume.value * 2);
      //         break;
      //       case AudioInterruptionType.pause:
      //         if (_playInterrupted) {}
      //         break;
      //       case AudioInterruptionType.unknown:
      //         break;
      //     }
      //     _playInterrupted = false;
      //   }
    });
  }
}
