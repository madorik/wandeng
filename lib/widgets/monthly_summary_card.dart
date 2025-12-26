import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 이달의 요약 데이터 모델
class MonthlySummaryData {
  final int year;
  final int month;
  final int totalClimbs;
  final int completedClimbs;
  final int lastMonthClimbs;
  final int monthlyGoal;
  final int climbingDays;
  final int totalVideos;
  final int totalMinutes;
  final String? maxDifficulty;
  final Map<String, int> difficultyStats;
  final String? mostVisitedGym;
  final int mostVisitedGymCount;
  final int visitedGymCount;

  const MonthlySummaryData({
    required this.year,
    required this.month,
    this.totalClimbs = 0,
    this.completedClimbs = 0,
    this.lastMonthClimbs = 0,
    this.monthlyGoal = 30,
    this.climbingDays = 0,
    this.totalVideos = 0,
    this.totalMinutes = 0,
    this.maxDifficulty,
    this.difficultyStats = const {},
    this.mostVisitedGym,
    this.mostVisitedGymCount = 0,
    this.visitedGymCount = 0,
  });
}

/// 이달의 요약 카드 위젯 (컴팩트 버전)
class MonthlySummaryCard extends StatelessWidget {
  final MonthlySummaryData? data;

  const MonthlySummaryCard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final summaryData = data ?? const MonthlySummaryData(
      year: 2024,
      month: 12,
      totalClimbs: 32,
      completedClimbs: 24,
      lastMonthClimbs: 18,
      monthlyGoal: 30,
      climbingDays: 8,
      totalVideos: 15,
      totalMinutes: 752,
      maxDifficulty: 'V5',
      difficultyStats: {
        'V0-V1': 8,
        'V2-V3': 6,
        'V4-V5': 8,
        'V6+': 2,
      },
      mostVisitedGym: '더클라임 강남점',
      mostVisitedGymCount: 5,
      visitedGymCount: 3,
    );

    final climbsIncrease = summaryData.completedClimbs - summaryData.lastMonthClimbs;
    final progress = summaryData.completedClimbs / summaryData.monthlyGoal;
    final hours = summaryData.totalMinutes ~/ 60;
    final completionRate = summaryData.totalClimbs > 0
        ? ((summaryData.completedClimbs / summaryData.totalClimbs) * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // 헤더 + 메인 통계
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 완등 횟수
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${summaryData.month}월 완등',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (climbsIncrease != 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: climbsIncrease > 0
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  climbsIncrease > 0
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 10,
                                  color: climbsIncrease > 0 ? AppColors.success : AppColors.error,
                                ),
                                Text(
                                  '${climbsIncrease.abs()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: climbsIncrease > 0 ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${summaryData.completedClimbs}',
                          style: AppTextStyles.numberLarge.copyWith(
                            fontSize: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          ' / ${summaryData.monthlyGoal}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 우측 미니 통계
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMiniStat('${summaryData.climbingDays}일', '등반'),
                  const SizedBox(height: 6),
                  _buildMiniStat('${hours}시간', '시간'),
                  const SizedBox(height: 6),
                  _buildMiniStat('$completionRate%', '완등률'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 14),

          // 하단 정보 (가장 많이 간 암장 + 난이도별)
          Row(
            children: [
              // 가장 많이 간 암장
              if (summaryData.mostVisitedGym != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          summaryData.mostVisitedGym!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${summaryData.mostVisitedGymCount}회',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              // 난이도별 미니 뱃지
              Row(
                children: _buildDifficultyBadges(summaryData.difficultyStats),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDifficultyBadges(Map<String, int> stats) {
    final colors = [
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.secondary,
    ];

    return stats.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final color = colors[index % colors.length];

      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${item.value}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      );
    }).toList();
  }
}
