import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../models/quote.dart';

const MethodChannel _shareChannel = MethodChannel('com.sample_app/share');

class ShareService {
  /// Share quote text via the system share sheet.
  static Future<void> shareText(Quote quote) async {
    await Share.share('"${quote.text}"\n\n— ${quote.author}', subject: 'Quote');
  }

  /// Share image bytes (writes to a temp file and invokes share sheet).
  static Future<void> shareImageBytes(Uint8List bytes, Quote quote) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/quote_card.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: '"${quote.text}"\n\n— ${quote.author}');
  }

  /// Save image bytes to the device gallery (requests permissions as needed).
  static Future<bool> saveImageToGallery(
    Uint8List bytes, {
    String? name,
  }) async {
    try {
      final granted = await _requestStoragePermission();
      if (!granted) return false;

      // write bytes to a temporary file then call platform channel to save
      final tempDir = await getTemporaryDirectory();
      final fileName =
          (name ?? 'quote_card_${DateTime.now().millisecondsSinceEpoch}') +
          '.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final result = await _shareChannel.invokeMethod<bool>(
        'saveImageToGallery',
        {'path': file.path, 'name': fileName},
      );
      return result == true;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return false;
    }
  }

  static Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else if (Platform.isIOS) {
        // On iOS we only need add-to-photos permission for saving images
        final status = await Permission.photosAddOnly.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }
    return true;
  }
}
