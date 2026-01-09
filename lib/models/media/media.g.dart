part of 'media.dart';

@pragma('vm:entry-point')
Future<Map<String, dynamic>> _parseLyric(args) async {
  try {
    final path = args["path"];

    final String fileNameWithoutExtension = path.replaceAll(
      RegExp(r'\.[^.]+$'),
      '',
    );

    final lyricFile = File('$fileNameWithoutExtension.lrc');

    final ttmlFile = File('$fileNameWithoutExtension.ttml');

    final lyricFileExistence = await lyricFile.exists();

    final ttmlFileExistence = await ttmlFile.exists();

    // 优先取lrc
    if (lyricFileExistence) {
      return await _handleParseLyricFile(fileNameWithoutExtension);
    } else if (ttmlFileExistence) {
      return await _handleParseLyricFile(fileNameWithoutExtension, "ttml");
    } else {
      final lyrics = readLyrics(path);

      if (lyrics != null) {
        final res = ParserSmart(lyrics).parseLines();

        return {"model": res, "raw": lyrics, "source": LyricSource.tag};
      }

      return {
        "model": List<LyricsLineModel>.empty(),
        "raw": "",
        "source": LyricSource.none,
      };
    }
  } catch (e) {
    return {
      "model": List<LyricsLineModel>.empty(),
      "raw": "",
      "source": LyricSource.none,
    };
  }
}

/// 解析同名的lrc文件
Future _handleParseLyricFile(String mediaPath, [String? extension]) async {
  final raw = File('$mediaPath.${extension ?? "lrc"}').readAsStringSync();

  return {
    "model": ParserSmart(raw).parseLines(),
    "raw": raw,
    "source": LyricSource.file,
  };
}
