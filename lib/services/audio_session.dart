import 'package:IceyPlayer/helpers/platform.dart';
import 'package:audio_session/audio_session.dart';
import 'package:IceyPlayer/models/media/media.dart';
import 'package:IceyPlayer/models/settings/settings.dart';

class AudioSessionHandler {
  late AudioSession session;
  bool _playInterrupted = false;

  Future<bool> setActive(bool active) async {
    if (PlatformHelper.isDesktop) return false;

    // 不与其他应用一起播放关闭时，不激活音频焦点
    if (active && !settingsManager.audioFocus.value) return false;

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

    // 耳机拔出暂停（无论 audioFocus 设置都暂停）
    session.becomingNoisyEventStream.listen((_) {
      mediaManager.pause();
    });

    // 音频中断事件处理
    session.interruptionEventStream.listen((event) {
      // 不与其他应用一起播放关闭时，忽略所有中断
      if (!settingsManager.audioFocus.value) return;

      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // 降低音量（暂不实现）
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            mediaManager.pause();
            _playInterrupted = true;
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // 恢复音量（暂不实现）
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_playInterrupted) {
              mediaManager.play();
            }
            _playInterrupted = false;
            break;
        }
      }
    });
  }
}
