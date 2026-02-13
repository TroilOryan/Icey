#include "include/audio_service_win/audio_service_win_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "audio_service_win_plugin.h"

void AudioServiceWinPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  audio_service_win::AudioServiceWinPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
