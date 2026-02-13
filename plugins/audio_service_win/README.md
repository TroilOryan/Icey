

<div align="center">
  <img src="assets/scrnshot1.png" alt="audio_service_win Windows SMTC Example" width="600"/>
  
  <h1 align="center"> audio_service_win</h1>
  
  <p align="center">
    <b>Windows System Media Transport Controls for <a href="https://pub.dev/packages/audio_service">audio_service</a></b>
  </p>
  
  <p align="center">
    <a href="https://pub.dev/packages/audio_service_win"><img src="https://img.shields.io/pub/v/audio_service_win.svg?style=flat-square&logo=dart" alt="pub version"></a>
    <a href="https://github.com/HemantKArya/audio_service_win/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square"></a>
    <img src="https://img.shields.io/badge/platform-windows-blue?style=flat-square&logo=windows" alt="platform: windows">
  </p>
</div>

<p align="center">
  <i>Bring rich media notifications, lock screen controls, and hardware media key support to your Flutter Windows apps..</i>
</p>

---

`audio_service_win` brings <b>System Media Transport Controls (SMTC)</b> support to Windows for the popular <a href="https://pub.dev/packages/audio_service">audio_service</a> plugin. This enables rich media notifications, lock screen controls, and hardware media key support for your Flutter apps on Windows.

---

## ✨ Features

- Windows System Media Transport Controls (SMTC) integration
- Media metadata (title, artist, album, artwork) display
- Media button events (play, pause, next, previous, etc.)
- Works with <a href="https://pub.dev/packages/audio_service">audio_service</a> platform interface
- Easy setup and configuration

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  audio_service_win: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## 🛠️ Usage

This package is a **platform implementation** for the [`audio_service`](https://pub.dev/packages/audio_service) plugin on Windows. You should use the `audio_service` API in your app, and this package will be used automatically on Windows if added as a dependency.

### Quick Example

Define your audio handler:

```dart
class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  // ...other callbacks...
}
```

Register your handler at app startup:

```dart
Future<void> main() async {
  final _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio', // required for Windows
      androidNotificationChannelName: 'Music playback',
    ),
  );
  runApp(MyApp());
}
```

Send requests to your handler:

```dart
_audioHandler.play();
_audioHandler.pause();
_audioHandler.seek(Duration(seconds: 10));
_audioHandler.addQueueItem(MediaItem(
  id: 'https://example.com/audio.mp3',
  album: 'Album name',
  title: 'Track title',
  artist: 'Artist name',
  artUri: Uri.parse('https://example.com/album.jpg'),
));
```

For more advanced usage, queue management, state broadcasting, and listening to state changes, **see the full documentation at [`audio_service`](https://pub.dev/packages/audio_service)**.

## 💻 Platform Support

| Platform | Supported |
|----------|-----------|
| Windows  |     ✅     |
| Android  |     `Already Supported`     |
| iOS      |     `Already Supported`     |
| macOS    |     `Already Supported`     |
| Linux    |     via `audio_service_mpris`     |

## 📸 Screenshot

<p align="center">
  <img src="assets/scrnshot1.png" alt="Windows SMTC Example" width="500"/>
</p>




## 📬 Contact

For questions, suggestions, or feedback, feel free to reach out:

- Email: [iamhemantindia@protonmail.com](mailto:iamhemantindia@protonmail.com)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

