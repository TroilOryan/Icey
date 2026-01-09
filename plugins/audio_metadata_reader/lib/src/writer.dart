import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audio_metadata_reader/src/metadata/base.dart';
import 'package:audio_metadata_reader/src/parsers/riff.dart';

/// Reads the metadata, allows modification via [updater], and writes it back.
///
/// The [updater] receives the specific metadata object (e.g Mp3Metadata).
/// You can modify this object directly within the callback.
void updateMetadata(String path, void Function(ParserTag metadata) updater) {
  final metadata = readAllMetadata(path);

  updater(metadata);

  writeMetadata(path, metadata);
}

/// Write the [metadata] into the [track]
void writeMetadata(String path, ParserTag metadata) {
  final file = File(path);

  final reader = file.openSync();

  if (ID3v2Parser.canUserParser(reader)) {
    Id3v4Writer().write(file, metadata as Mp3Metadata);
  } else if (MP4Parser.canUserParser(reader)) {
    Mp4Writer().write(file, metadata as Mp4Metadata);
  } else if (FlacParser.canUserParser(reader)) {
    FlacWriter().write(file, metadata as VorbisMetadata);
  } else if (RiffParser.canUserParser(reader)) {
    RiffWriter().write(file, metadata as RiffMetadata);
  } else if (ID3v1Parser.canUserParser(reader)) {
    ID3v1Writer().write(file, metadata as Mp3Metadata);
  }
}
