import 'dart:async';
import 'package:flutter/material.dart';
import './lyric_model.dart';
import './lyric_view.dart';
import './sample_lyrics.dart';

/// 歌词展示示例页面
/// 模拟Apple Music风格的歌词播放界面
class LyricScreen extends StatefulWidget {
  const LyricScreen({super.key});

  @override
  State<LyricScreen> createState() => _LyricScreenState();
}

class _LyricScreenState extends State<LyricScreen> 
    with TickerProviderStateMixin {
  /// 当前播放时间
  Duration _currentTime = Duration.zero;
  
  /// 总时长
  final Duration _totalDuration = const Duration(seconds: 52);
  
  /// 是否正在播放
  bool _isPlaying = false;
  
  /// 播放计时器
  Timer? _playTimer;
  
  /// 歌词数据
  late Lyrics _lyrics;
  
  /// 是否显示翻译
  bool _showTranslation = true;
  
  /// 播放速度
  final double _playbackSpeed = 1.0;
  
  /// 动画控制器
  late AnimationController _playButtonController;
  
  /// 当前播放行距离顶部的偏移
  double _activeLineTopOffset = 150;
  
  /// 是否启用模糊效果
  bool _enableBlur = true;
  
  /// 是否启用边缘模糊
  bool _enableEdgeBlur = true;

  @override
  void initState() {
    super.initState();
    _lyrics = SampleLyrics.demoSong;
    _playButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _playButtonController.dispose();
    super.dispose();
  }

  /// 切换播放/暂停
  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _playButtonController.forward();
        _startPlayback();
      } else {
        _playButtonController.reverse();
        _stopPlayback();
      }
    });
  }

  /// 开始播放
  void _startPlayback() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _currentTime += Duration(milliseconds: (16 * _playbackSpeed).round());
        
        // 循环播放
        if (_currentTime >= _totalDuration) {
          _currentTime = Duration.zero;
        }
      });
    });
  }

  /// 停止播放
  void _stopPlayback() {
    _playTimer?.cancel();
  }

  /// 跳转到指定时间
  void _seekTo(Duration position) {
    setState(() {
      _currentTime = position;
    });
  }

  /// 跳转到指定行
  void _seekToLine(int index, LyricLine line) {
    _seekTo(line.start);
  }

  /// 格式化时间
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景渐变
          _buildBackground(),
          
          // 歌词内容
          SafeArea(
            child: Column(
              children: [
                // 顶部信息栏
                _buildHeader(),
                
                // 歌词视图
                Expanded(
                  child: LyricView(
                    lyrics: _lyrics,
                    currentTime: _currentTime,
                    showTranslation: _showTranslation,
                    activeLineTopOffset: _activeLineTopOffset,
                    scrollDuration: const Duration(milliseconds: 400),
                    scrollCurve: Curves.easeOutCubic,
                    enableBlur: _enableBlur,
                    blurSigma: 3.0,
                    enableEdgeBlur: _enableEdgeBlur,
                    edgeBlurHeight: 120,
                    onLineTap: _seekToLine,
                    baseStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                    highlightStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    translationStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.3,
                    ),
                    translationHighlightStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.3,
                    ),
                    lineSpacing: 20,
                  ),
                ),
                
                // 底部控制栏
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建背景
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部信息栏
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // 下拉指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 歌曲信息
          Row(
            children: [
              // 专辑封面
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.indigo.shade300,
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 歌曲名称和艺术家
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lyrics.title ?? '未知歌曲',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lyrics.artist ?? '未知艺术家',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 翻译开关
              IconButton(
                onPressed: () {
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                icon: Icon(
                  _showTranslation ? Icons.translate : Icons.translate_outlined,
                  color: _showTranslation ? Colors.white : Colors.white54,
                ),
              ),
              
              // 模糊效果开关
              IconButton(
                onPressed: () {
                  setState(() {
                    _enableBlur = !_enableBlur;
                  });
                },
                icon: Icon(
                  _enableBlur ? Icons.blur_on : Icons.blur_off,
                  color: _enableBlur ? Colors.white : Colors.white54,
                ),
              ),
              
              // 边缘模糊开关
              IconButton(
                onPressed: () {
                  setState(() {
                    _enableEdgeBlur = !_enableEdgeBlur;
                  });
                },
                icon: Icon(
                  _enableEdgeBlur ? Icons.gradient : Icons.gradient_outlined,
                  color: _enableEdgeBlur ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 位置调节滑块
          _buildOffsetSlider(),
        ],
      ),
    );
  }
  
  /// 构建位置偏移调节滑块
  Widget _buildOffsetSlider() {
    return Row(
      children: [
        Text(
          '位置',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: Colors.white38,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: _activeLineTopOffset,
              min: 50,
              max: 300,
              onChanged: (value) {
                setState(() {
                  _activeLineTopOffset = value;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${_activeLineTopOffset.round()}px',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建底部控制栏
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          _buildProgressBar(),
          
          const SizedBox(height: 16),
          
          // 播放控制
          _buildPlayControls(),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentTime.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              _seekTo(Duration(
                milliseconds: (value * _totalDuration.inMilliseconds).round(),
              ));
            },
          ),
        ),
        
        // 时间显示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建播放控制
  Widget _buildPlayControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 后退
        IconButton(
          onPressed: () {
            final newTime = _currentTime - const Duration(seconds: 15);
            _seekTo(newTime.isNegative ? Duration.zero : newTime);
          },
          icon: const Icon(Icons.fast_rewind),
          iconSize: 36,
          color: Colors.white70,
        ),
        
        const SizedBox(width: 24),
        
        // 播放/暂停按钮
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _playButtonController,
              color: Colors.black,
              size: 36,
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 前进
        IconButton(
          onPressed: () {
            final newTime = _currentTime + const Duration(seconds: 15);
            _seekTo(newTime > _totalDuration ? _totalDuration : newTime);
          },
          icon: const Icon(Icons.fast_forward),
          iconSize: 36,
          color: Colors.white70,
        ),
      ],
    );
  }
}
