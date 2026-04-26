# CLAUDE.md

This file provides guidance to Kscc (claudexxxxxx.ai/code) when working with code in this repository.

## Project Overview

Icey 是一个使用 Flutter 开发的本地音乐播放器，支持 Android、iOS、Windows、macOS、Linux 平台。通过 Rust (flutter_rust_bridge) 实现音标签读取和歌词解析等高性能操作。

Flutter 版本: 3.41.6 (通过 FVM 管理，配置在 `.fvmrc`)

## Common Commands

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建 Android release
flutter build apk --release --obfuscate --split-debug-info=/debug/files --target-platform android-arm64

# 构建 Windows
flutter build windows

# 静态分析
flutter analyze

# 运行测试
flutter test
```

## Architecture

### 状态管理 — Signals

使用 `signals` / `signals_flutter` 包，类似 MobX 的响应式状态管理。全局信号实例定义在 `lib/state.dart`:
- `mediaManager` — 媒体管理（曲库、播放队列）
- `settingsManager` — 应用设置
- `appState` — 应用全局状态

### 路由 — Go Router

路由配置在 `lib/router/router.dart`，使用 `StatefulShellRoute` 实现底部标签页导航（曲库、专辑、歌手、设置）。

### 音频服务 — audio_service + just_audio

核心音频逻辑在 `lib/services/audio_service.dart`。`AudioServiceHandler` 继承 `BaseAudioHandler` 并实现 `SeekHandler`，管理播放队列、随机播放、播放模式。通过 `audio_service` 包集成系统通知栏控制。

### 数据持久化 — Hive CE

本地存储使用 Hive CE (NoSQL)。Box 键定义在 `lib/constants/box_key.dart`。主要 Box：
- `media` — 媒体元数据缓存
- `settings` — 用户设置
- `liked` — 喜欢的歌曲
- `mediaCount` — 播放计数
- `mediaOrder` — 播放列表顺序

Entity 定义在 `lib/entities/`，需要 Hive adapter（通过 `@HiveType` 注解 + codegen）。

### Rust FFI Bridge

通过 `flutter_rust_bridge` 集成 Rust 原生库。Rust 代码在 `rust/` 目录，主要功能：
- 音频标签读取（lofty crate）
- 歌词解析（amll-lyric）— 支持 LRC、QRC、TTML、ESLRC、YRC、LYS 格式

Dart 侧桥接代码在 `lib/src/`。

### 本地插件

`plugins/` 目录包含项目级本地插件：
- `audio_query` — 本地音频文件扫描
- `audio_service_win` — Windows 音频服务
- `flutter_lyric` — 歌词显示组件
- `open_app` — 应用启动工具
- `super_sliver_list` — 高性能列表组件

### 初始化流程

`main.dart` 中按顺序调用：
1. `init/hive.dart` — 初始化 Hive 数据库
2. `init/services.dart` — 初始化音频服务和媒体管理
3. `init/desktop.dart` — 桌面端窗口和托盘初始化

### 关键目录

| 目录 | 用途 |[play_list.dart](lib/components/play_list_button/play_list.dart)
|------|------|
| `lib/pages/` | 页面/屏幕 |
| `lib/components/` | 可复用 UI 组件 |
| `lib/models/` | 业务逻辑模型 |
| `lib/services/` | 音频播放服务 |
| `lib/entities/` | Hive 数据实体 |
| `lib/helpers/` | 工具类（平台检测、日志等） |
| `lib/http/` | Dio HTTP 客户端配置 |
| `lib/theme/` | 主题配置 |
| `lib/constants/` | 常量定义 |
