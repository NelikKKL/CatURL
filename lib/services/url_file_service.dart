import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';
import '../models/url_entry.dart';

class UrlFileService {
  static const _storageKey = 'url_entries';

  /// Creates a Windows-style .url shortcut file
  static Future<String> createUrlFile({
    required String name,
    required String url,
    required String directory,
  }) async {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filePath = '$directory/$sanitized.url';

    final content = '[InternetShortcut]\nURL=$url\n';
    final file = File(filePath);
    await file.writeAsString(content);
    return filePath;
  }

  /// Parse a .url file and extract the URL
  static Future<String?> parseUrlFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final lines = content.split('\n');

      for (final line in lines) {
        if (line.trim().startsWith('URL=')) {
          return line.trim().substring(4).trim();
        }
      }
    } catch (e) {
      debugPrint('Error parsing .url file: $e');
    }
    return null;
  }

  /// Open a URL in the default browser
  static Future<bool> openUrl(String url) async {
    try {
      String normalized = url.trim();
      if (!normalized.startsWith('http://') &&
          !normalized.startsWith('https://')) {
        normalized = 'https://$normalized';
      }
      final uri = Uri.parse(normalized);
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
    return false;
  }

  /// Open a .url file using system file associations (shows "open with" dialog)
  static Future<bool> openUrlFileWithSystem(String filePath) async {
    final result = await OpenFilex.open(filePath);
    return result.type == ResultType.done;
  }

  /// Get the default save directory for .url files
  static Future<String> getDefaultDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final urlDir = Directory('${dir.path}/URL Shortcuts');
    if (!await urlDir.exists()) {
      await urlDir.create(recursive: true);
    }
    return urlDir.path;
  }

  /// Save entries list to SharedPreferences
  static Future<void> saveEntries(List<UrlEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Load entries from SharedPreferences
  static Future<List<UrlEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    final entries = <UrlEntry>[];

    for (final json in jsonList) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final entry = UrlEntry.fromJson(map);
        // Check if file still exists
        if (await File(entry.filePath).exists()) {
          entries.add(entry);
        }
      } catch (_) {}
    }

    return entries;
  }

  /// Delete a .url file and remove from storage
  static Future<void> deleteEntry(UrlEntry entry, List<UrlEntry> entries) async {
    try {
      final file = File(entry.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    entries.removeWhere((e) => e.id == entry.id);
    await saveEntries(entries);
  }
}
