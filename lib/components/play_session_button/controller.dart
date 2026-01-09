part of 'play_session_button.dart';

enum AudioDeviceTypeText {
  unknown(
    value: AudioDeviceType.unknown,
    name: "未知设备",
    icon: Icons.device_unknown,
  ),
  speaker(
    value: AudioDeviceType.builtInSpeaker,
    name: "扬声器",
    icon: Icons.volume_up,
  ),
  bluetooth(
    value: AudioDeviceType.bluetoothA2dp,
    name: "蓝牙",
    icon: Icons.bluetooth,
  );

  const AudioDeviceTypeText({
    required this.value,
    required this.name,
    required this.icon,
  });

  final AudioDeviceType value;
  final String name;
  final IconData icon;

  static AudioDeviceTypeText getByValue(AudioDeviceType value) {
    return values.firstWhere((element) => element.value == value);
  }

  static AudioDeviceTypeText getByName(String value) {
    return values.firstWhere((element) => element.name == value);
  }
}

class PlaySessionButonController {
  final state = PlaySessionButtonState();

  Future<void> onInit() async {
    final session = await AudioSession.instance;

    session.devicesStream.listen((devices) {
      state.devices.value = devices
          .where(
            (e) =>
                e.isOutput &&
                (e.type.name.toLowerCase().contains("speaker") ||
                    e.type.name.toLowerCase().contains("bluetootha2dp")),
          )
          .toList();
    });
  }

  Future<void> _switchToDevice(AudioDeviceType type) async {
    try {
      bool success = false;

      switch (type) {
        // case AudioDeviceType.builtInSpeaker:
        //   success = await switchToReceiver();
        //   break;
        case AudioDeviceType.builtInSpeaker:
          success = await switchToSpeaker();
          break;
        case AudioDeviceType.wiredHeadphones:
          success = await switchToHeadphones();
          break;
        case AudioDeviceType.bluetoothA2dp:
        case AudioDeviceType.bluetoothLe:
        case AudioDeviceType.bluetoothSco:
          success = await switchToBluetooth();
          break;
        default:
          return;
      }

      if (success) {
      } else {}
    } catch (e) {}
  }

  final _androidAudioManager = !kIsWeb && Platform.isAndroid
      ? AndroidAudioManager()
      : null;
  final _avAudioSession = !kIsWeb && Platform.isIOS ? AVAudioSession() : null;

  Future<bool> switchToSpeaker() async {
    if (_androidAudioManager != null) {
      await _androidAudioManager!.setMode(
        AndroidAudioHardwareMode.inCommunication,
      );
      await _androidAudioManager!.stopBluetoothSco();
      await _androidAudioManager!.setBluetoothScoOn(false);
      await _androidAudioManager!.setSpeakerphoneOn(true);
    } else if (_avAudioSession != null) {
      await _avAudioSession!.overrideOutputAudioPort(
        AVAudioSessionPortOverride.speaker,
      );
    }
    return true;
  }

  Future<bool> switchToReceiver() async {
    if (_androidAudioManager != null) {
      _androidAudioManager!.setMode(AndroidAudioHardwareMode.inCommunication);
      _androidAudioManager!.stopBluetoothSco();
      _androidAudioManager!.setBluetoothScoOn(false);
      _androidAudioManager!.setSpeakerphoneOn(false);
      return true;
    } else if (_avAudioSession != null) {
      return await _switchToAnyIosPortIn({AVAudioSessionPort.builtInMic});
    }
    return false;
  }

  Future<bool> switchToHeadphones() async {
    if (_androidAudioManager != null) {
      _androidAudioManager!.setMode(AndroidAudioHardwareMode.inCommunication);
      _androidAudioManager!.stopBluetoothSco();
      _androidAudioManager!.setBluetoothScoOn(false);
      _androidAudioManager!.setSpeakerphoneOn(false);
      return true;
    } else if (_avAudioSession != null) {
      return await _switchToAnyIosPortIn({AVAudioSessionPort.headsetMic});
    }
    return true;
  }

  Future<bool> switchToBluetooth() async {
    if (_androidAudioManager != null) {
      await _androidAudioManager!.setMode(
        AndroidAudioHardwareMode.inCommunication,
      );

      await _androidAudioManager!.setSpeakerphoneOn(false);
      await _androidAudioManager!.startBluetoothSco();
      await _androidAudioManager!.setBluetoothScoOn(true);
      return true;
    } else if (_avAudioSession != null) {
      return await _switchToAnyIosPortIn({
        AVAudioSessionPort.bluetoothLe,
        AVAudioSessionPort.bluetoothHfp,
        AVAudioSessionPort.bluetoothA2dp,
      });
    }
    return false;
  }

  Future<bool> _switchToAnyIosPortIn(Set<AVAudioSessionPort> ports) async {
    if ((await _avAudioSession!.currentRoute).outputs.any(
      (r) => ports.contains(r.portType),
    )) {
      return true;
    }
    for (var input in await _avAudioSession!.availableInputs) {
      if (ports.contains(input.portType)) {
        await _avAudioSession!.setPreferredInput(input);
      }
    }
    return false;
  }
}
