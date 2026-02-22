import 'package:flutter/material.dart';

class ClimbRecord {
  final int? id;
  final String visitorId;
  final String gymName;
  final String difficulty;
  final bool isCompleted;
  final List<String> tags;
  final String? videoPath;
  final String? thumbnailPath;
  final DateTime recordedAt;
  final int duration;

  ClimbRecord({
    this.id,
    this.visitorId = 'local_user',
    required this.gymName,
    required this.difficulty,
    required this.isCompleted,
    this.tags = const [],
    this.videoPath,
    this.thumbnailPath,
    required this.recordedAt,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'visitor_id': visitorId,
        'gym_name': gymName,
        'difficulty': difficulty,
        'is_completed': isCompleted ? 1 : 0,
        'tags': tags.join(','),
        'video_path': videoPath,
        'thumbnail_path': thumbnailPath,
        'recorded_at': recordedAt.toIso8601String(),
        'duration': duration,
      };

  factory ClimbRecord.fromMap(Map<String, dynamic> map) => ClimbRecord(
        id: map['id'] as int?,
        visitorId: map['visitor_id'] as String? ?? 'local_user',
        gymName: map['gym_name'] as String,
        difficulty: map['difficulty'] as String,
        isCompleted: (map['is_completed'] as int) == 1,
        tags: (map['tags'] as String?)
                ?.split(',')
                .where((t) => t.isNotEmpty)
                .toList() ??
            [],
        videoPath: map['video_path'] as String?,
        thumbnailPath: map['thumbnail_path'] as String?,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
        duration: map['duration'] as int? ?? 0,
      );

  ClimbRecord copyWith({
    int? id,
    String? visitorId,
    String? gymName,
    String? difficulty,
    bool? isCompleted,
    List<String>? tags,
    String? videoPath,
    String? thumbnailPath,
    DateTime? recordedAt,
    int? duration,
  }) {
    return ClimbRecord(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      gymName: gymName ?? this.gymName,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
      videoPath: videoPath ?? this.videoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      recordedAt: recordedAt ?? this.recordedAt,
      duration: duration ?? this.duration,
    );
  }

  Color get difficultyColor =>
      _difficultyColorMap[difficulty] ?? const Color(0xFF9E9E9E);

  static const _difficultyColorMap = {
    'V0': Color(0xFFFFFFFF),
    'V1': Color(0xFFFFEB3B),
    'V2': Color(0xFFFF9800),
    'V3': Color(0xFF66BB6A),
    'V4': Color(0xFF42A5F5),
    'V5': Color(0xFFEF5350),
    'V6': Color(0xFF7E57C2),
    'V7+': Color(0xFF424242),
  };
}
