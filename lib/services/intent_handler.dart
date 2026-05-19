import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class IntentHandler {
  static const _channel = MethodChannel('io.github.caturl.caturl/intent');

  static Future<String?> getSharedFilePath() async {
    try {
      final path = await _channel.invokeMethod<String>('getSharedFilePath');
      return path;
    } catch (e) {
      debugPrint('IntentHandler error: $e');
      return null;
    }
  }

  /// Opens the native Android file picker (ACTION_GET_CONTENT).
  /// Returns the resolved local file path, or null if cancelled.
  static Future<String?> openFilePicker() async {
    try {
      final path = await _channel.invokeMethod<String>('openFilePicker');
      return path;
    } catch (e) {
      debugPrint('IntentHandler openFilePicker error: $e');
      return null;
    }
  }
}
