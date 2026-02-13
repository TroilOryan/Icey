#ifndef FLUTTER_PLUGIN_AUDIO_SERVICE_WIN_PLUGIN_H_
#define FLUTTER_PLUGIN_AUDIO_SERVICE_WIN_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace audio_service_win {

class AudioServiceWinPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AudioServiceWinPlugin();

  virtual ~AudioServiceWinPlugin();

  // Disallow copy and assign.
  AudioServiceWinPlugin(const AudioServiceWinPlugin&) = delete;
  AudioServiceWinPlugin& operator=(const AudioServiceWinPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace audio_service_win

#endif  // FLUTTER_PLUGIN_AUDIO_SERVICE_WIN_PLUGIN_H_
