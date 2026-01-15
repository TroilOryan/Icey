import 'dart:io';

import 'package:catcher_2/model/platform_type.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:catcher_2/model/report.dart' as catcher;

import 'json_file_handler.dart';

abstract final class LogsHelper {
  static File? _logFile;

  static Future<File> getLogsPath() async {
    if (_logFile != null) return _logFile!;

    String dir = (await getApplicationDocumentsDirectory()).path;
    final String filename = p.join(dir, '.pili_logs.json');
    final File file = File(filename);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return _logFile = file;
  }

  static Future<bool> clearLogs() async {
    try {
      await JsonFileHandler.add(
        (raf) => raf.setPosition(0).then((raf) => raf.truncate(0)),
      );
    } catch (e) {
      // if (kDebugMode) debugPrint('Error clearing file: $e');
      return false;
    }
    return true;
  }
}

class Report extends catcher.Report {
  Report(
    super.error,
    super.stackTrace,
    super.dateTime,
    super.deviceParameters,
    super.applicationParameters,
    super.customParameters,
    super.errorDetails,
    super.platformType,
    super.screenshot,
  );

  bool isExpanded = false;

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    json['error'],
    json['stackTrace'],
    DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime(1970),
    json['deviceParameters'] ?? const {},
    json['applicationParameters'] ?? const {},
    json['customParameters'] ?? const {},
    null,
    PlatformType.values.byName(json['platformType']),
    null,
  );

  Report copyWith({
    dynamic error,
    dynamic stackTrace,
    DateTime? dateTime,
    Map<String, dynamic>? deviceParameters,
    Map<String, dynamic>? applicationParameters,
    Map<String, dynamic>? customParameters,
    FlutterErrorDetails? errorDetails,
    PlatformType? platformType,
  }) {
    return Report(
      error ?? this.error,
      stackTrace ?? this.stackTrace,
      dateTime ?? this.dateTime,
      deviceParameters ?? this.deviceParameters,
      applicationParameters ?? this.applicationParameters,
      customParameters ?? this.customParameters,
      errorDetails ?? this.errorDetails,
      platformType ?? this.platformType,
      null,
    );
  }

  String _params2String(Map<String, dynamic> params) {
    return params.entries
        .map((entry) => '${entry.key}: ${entry.value}\n')
        .join();
  }

  @override
  String toString() {
    return '------- DEVICE INFO -------\n${_params2String(deviceParameters)}'
        '------- APP INFO -------\n${_params2String(applicationParameters)}'
        '------- ERROR -------\n$error\n'
        '------- STACK TRACE -------\n${stackTrace.toString().trim()}\n'
        '------- CUSTOM INFO -------\n${_params2String(customParameters)}';
  }
}
