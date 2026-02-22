import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailHelper {
  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailDir = '${appDir.path}/Thumbnails';
      await Directory(thumbnailDir).create(recursive: true);

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailDir,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('썸네일 생성 오류: $e');
      return null;
    }
  }
}
