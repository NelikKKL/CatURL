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
}
