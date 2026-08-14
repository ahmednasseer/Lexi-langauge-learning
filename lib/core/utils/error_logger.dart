import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ErrorLogger {
  static File? _logFile;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/error_log.txt');
      if (await _logFile!.exists()) {
        await _logFile!.writeAsString('--- New Session Started ---\n', mode: FileMode.append);
      } else {
        await _logFile!.writeAsString('--- New Session Started ---\n');
      }
    } catch (e) {
      debugPrint('ErrorLogger init failed: $e');
    }
  }

  static Future<void> logError(String error, {StackTrace? stackTrace}) async {
    if (!_initialized) await init();
    if (_logFile == null) {
      debugPrint('ERROR: $error');
      return;
    }
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] ERROR: $error');
    if (stackTrace != null) {
      buffer.writeln('Stack Trace: $stackTrace');
    }
    buffer.writeln('---');

    await _logFile!.writeAsString(buffer.toString(), mode: FileMode.append);

    if (kDebugMode) {
      debugPrint('Error logged: $error');
    }
  }

  static Future<void> logWarning(String warning) async {
    if (!_initialized) await init();
    if (_logFile == null) {
      debugPrint('WARNING: $warning');
      return;
    }
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] WARNING: $warning');
    buffer.writeln('---');

    await _logFile!.writeAsString(buffer.toString(), mode: FileMode.append);
  }

  static Future<void> logInfo(String info) async {
    if (!_initialized) await init();
    if (_logFile == null) {
      debugPrint('INFO: $info');
      return;
    }
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] INFO: $info');
    buffer.writeln('---');

    await _logFile!.writeAsString(buffer.toString(), mode: FileMode.append);
  }
}
