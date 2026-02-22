import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../models/climb_record.dart';

/// 전체 기록 Provider
final allClimbRecordsProvider = FutureProvider<List<ClimbRecord>>((ref) async {
  return await DatabaseHelper.instance.getAllClimbRecords();
});

/// 날짜별 기록 Provider
final recordsByDateProvider =
    FutureProvider.family<List<ClimbRecord>, DateTime>((ref, date) async {
  return await DatabaseHelper.instance.getClimbRecordsByDate(date);
});

/// 월별 기록 (날짜 키 그룹핑) Provider
final recordsByMonthProvider =
    FutureProvider.family<Map<String, List<ClimbRecord>>, ({int year, int month})>(
        (ref, params) async {
  return await DatabaseHelper.instance
      .getClimbRecordsByMonth(params.year, params.month);
});

/// 최근 기록 Provider
final recentClimbRecordsProvider =
    FutureProvider.family<List<ClimbRecord>, int>((ref, limit) async {
  return await DatabaseHelper.instance.getRecentClimbRecords(limit: limit);
});

/// 월간 등반 횟수 Provider
final monthlyClimbCountProvider =
    FutureProvider.family<int, ({int year, int month})>((ref, params) async {
  return await DatabaseHelper.instance
      .getMonthlyClimbCount(params.year, params.month);
});

/// 월간 완등 횟수 Provider
final monthlyCompletedCountProvider =
    FutureProvider.family<int, ({int year, int month})>((ref, params) async {
  final records = await DatabaseHelper.instance
      .getClimbRecordsByMonth(params.year, params.month);
  int count = 0;
  for (final list in records.values) {
    count += list.where((r) => r.isCompleted).length;
  }
  return count;
});

/// 월간 총 기록 수 Provider
final monthlyTotalCountProvider =
    FutureProvider.family<int, ({int year, int month})>((ref, params) async {
  final records = await DatabaseHelper.instance
      .getClimbRecordsByMonth(params.year, params.month);
  int count = 0;
  for (final list in records.values) {
    count += list.length;
  }
  return count;
});

/// 월간 통계 Provider (HomeScreen에서 사용)
final monthlySummaryProvider =
    FutureProvider.family<MonthlySummary, ({int year, int month})>(
        (ref, params) async {
  final records = await DatabaseHelper.instance
      .getClimbRecordsByMonth(params.year, params.month);

  int totalClimbs = 0;
  int completedClimbs = 0;
  int totalDuration = 0;
  String? maxDifficulty;
  int maxDifficultyValue = -1;
  final Map<String, int> gymVisitCounts = {};
  final Map<String, int> difficultyStats = {
    'V0-V1': 0,
    'V2-V3': 0,
    'V4-V5': 0,
    'V6+': 0,
  };

  for (final list in records.values) {
    for (final r in list) {
      totalClimbs++;
      if (r.isCompleted) completedClimbs++;
      totalDuration += r.duration;

      // 난이도 파싱
      final vNum = _parseDifficulty(r.difficulty);
      if (vNum > maxDifficultyValue) {
        maxDifficultyValue = vNum;
        maxDifficulty = r.difficulty;
      }

      // 난이도별 통계
      if (vNum <= 1) {
        difficultyStats['V0-V1'] = (difficultyStats['V0-V1'] ?? 0) + 1;
      } else if (vNum <= 3) {
        difficultyStats['V2-V3'] = (difficultyStats['V2-V3'] ?? 0) + 1;
      } else if (vNum <= 5) {
        difficultyStats['V4-V5'] = (difficultyStats['V4-V5'] ?? 0) + 1;
      } else {
        difficultyStats['V6+'] = (difficultyStats['V6+'] ?? 0) + 1;
      }

      // 암장별 방문 횟수
      gymVisitCounts[r.gymName] = (gymVisitCounts[r.gymName] ?? 0) + 1;
    }
  }

  String? mostVisitedGym;
  int mostVisitedGymCount = 0;
  for (final entry in gymVisitCounts.entries) {
    if (entry.value > mostVisitedGymCount) {
      mostVisitedGymCount = entry.value;
      mostVisitedGym = entry.key;
    }
  }

  return MonthlySummary(
    year: params.year,
    month: params.month,
    totalClimbs: totalClimbs,
    completedClimbs: completedClimbs,
    climbingDays: records.keys.length,
    totalMinutes: totalDuration ~/ 60,
    maxDifficulty: maxDifficulty,
    difficultyStats: difficultyStats,
    mostVisitedGym: mostVisitedGym,
    mostVisitedGymCount: mostVisitedGymCount,
    visitedGymCount: gymVisitCounts.keys.length,
  );
});

int _parseDifficulty(String difficulty) {
  final match = RegExp(r'V(\d+)').firstMatch(difficulty);
  if (match != null) return int.parse(match.group(1)!);
  return 0;
}

/// 월간 요약 데이터 클래스
class MonthlySummary {
  final int year;
  final int month;
  final int totalClimbs;
  final int completedClimbs;
  final int climbingDays;
  final int totalMinutes;
  final String? maxDifficulty;
  final Map<String, int> difficultyStats;
  final String? mostVisitedGym;
  final int mostVisitedGymCount;
  final int visitedGymCount;

  const MonthlySummary({
    required this.year,
    required this.month,
    this.totalClimbs = 0,
    this.completedClimbs = 0,
    this.climbingDays = 0,
    this.totalMinutes = 0,
    this.maxDifficulty,
    this.difficultyStats = const {},
    this.mostVisitedGym,
    this.mostVisitedGymCount = 0,
    this.visitedGymCount = 0,
  });
}
