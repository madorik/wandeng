import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/climb_record.dart';

/// 백엔드 API 서비스
class ApiService {
  // Android 에뮬레이터에서 localhost 접근 시 10.0.2.2 사용
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static const String _apiPrefix = '/api';

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  String? _userId;

  /// 현재 사용자 ID 가져오기 (없으면 생성)
  Future<String> getUserId() async {
    if (_userId != null) return _userId!;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');

    if (_userId == null) {
      _userId = await _createUser();
      await prefs.setString('user_id', _userId!);
    }

    return _userId!;
  }

  /// 새 사용자 생성
  Future<String> _createUser() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_apiPrefix/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': '클라이머'}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('[API] 사용자 생성 완료: ${data['id']}');
        return data['id'] as String;
      }
      throw Exception('사용자 생성 실패: ${response.statusCode}');
    } catch (e) {
      debugPrint('[API] 사용자 생성 오류: $e');
      rethrow;
    }
  }

  /// 영상 업로드
  Future<String?> uploadVideo(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_apiPrefix/upload/video'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'video',
        filePath,
        contentType: MediaType('video', 'mp4'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final uploadedPath = data['filePath'] as String;
        debugPrint('[API] 영상 업로드 완료: $uploadedPath');
        return uploadedPath;
      }
      debugPrint('[API] 영상 업로드 실패: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('[API] 영상 업로드 오류: $e');
      return null;
    }
  }

  /// 클라이밍 기록 저장
  Future<bool> createClimbRecord({
    required String gymName,
    required String difficulty,
    required bool isCompleted,
    required List<String> tags,
    required int duration,
    String? videoPath,
    String? thumbnailPath,
    DateTime? recordedAt,
  }) async {
    try {
      final userId = await getUserId();

      final body = {
        'visitorId': userId,
        'gymName': gymName,
        'difficulty': difficulty,
        'isCompleted': isCompleted,
        'tags': tags,
        'duration': duration,
        if (videoPath != null) 'videoPath': videoPath,
        if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
        if (recordedAt != null) 'recordedAt': recordedAt.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_apiPrefix/climb-records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('[API] 기록 저장 완료: id=${data['id']}, gym=$gymName');
        return true;
      }
      debugPrint('[API] 기록 저장 실패: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('[API] 기록 저장 오류: $e');
      return false;
    }
  }

  /// 월별 클라이밍 기록 조회
  Future<Map<String, List<ClimbRecord>>> getClimbRecordsByMonth(
      int year, int month) async {
    try {
      final monthStr = '$year-${month.toString().padLeft(2, '0')}';
      final userId = await getUserId();

      final response = await http.get(
        Uri.parse(
            '$_baseUrl$_apiPrefix/climb-records?month=$monthStr&visitorId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('[API] $monthStr 기록 조회: ${data.length}건');

        final Map<String, List<ClimbRecord>> grouped = {};
        for (final item in data) {
          final record = _parseClimbRecord(item);
          final dateKey = _formatDateKey(record.recordedAt);
          grouped.putIfAbsent(dateKey, () => []).add(record);
        }
        return grouped;
      }
      debugPrint('[API] 기록 조회 실패: ${response.statusCode}');
      return {};
    } catch (e) {
      debugPrint('[API] 기록 조회 오류: $e');
      return {};
    }
  }

  /// 전체 기록 조회
  Future<List<ClimbRecord>> getAllClimbRecords() async {
    try {
      final userId = await getUserId();
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPrefix/climb-records?visitorId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => _parseClimbRecord(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[API] 전체 기록 조회 오류: $e');
      return [];
    }
  }

  /// API 응답을 ClimbRecord로 변환
  ClimbRecord _parseClimbRecord(Map<String, dynamic> json) {
    return ClimbRecord(
      id: null, // 서버 ID는 UUID (String), 로컬 모델은 int → null 처리
      visitorId: json['visitorId'] as String? ?? 'local_user',
      gymName: json['gymName'] as String,
      difficulty: json['difficulty'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoPath: json['videoPath'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String).toLocal(),
      duration: json['duration'] as int? ?? 0,
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
