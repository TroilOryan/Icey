import 'package:IceyPlayer/constants/box_key.dart';
import 'package:IceyPlayer/constants/cache_key.dart';
import 'package:signals/signals.dart';

final proManager = ProManager();

final _settingsBox = Boxes.settingsBox;

class ProManager {
  final Signal<bool> _enabled;

  ProManager() : _enabled = signal(false) {
    _enabled.value = _settingsBox.get(
      CacheKey.Settings.pro,
      defaultValue: false,
    );
  }

  Signal<bool> get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled.value = value;

    _settingsBox.put(CacheKey.Settings.pro, value);
  }
}
