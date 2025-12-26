import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 이달의 요약 데이터 모델
class MonthlySummaryData {
  final int year;
  final int month;
  final int totalClimbs; // 총 등반 시도 수
  final int completedClimbs; // 완등 횟수
  final int lastMonthClimbs; // 지난달 완등 수
  final int monthlyGoal; // 이번달 목표
  final int climbingDays; // 등반 일수
  final int totalVideos; // 촬영 영상 수
  final int totalMinutes; // 총 등반 시간 (분)
  final String? maxDifficulty; // 최고 완등 난이도
  final Map<String, int> difficultyStats; // 난이도별 완등 수
  final String? mostVisitedGym; // 가장 많이 방문한 암장
  final int mostVisitedGymCount; // 가장 많이 방문한 암장 방문 횟수
  final int visitedGymCount; // 방문한 암장 수

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

/// 이달의 요약 카드 위젯
class MonthlySummaryCard extends StatelessWidget {
  final MonthlySummaryData? data;

  const MonthlySummaryCard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 데이터로 교체
    final summaryData = data ?? const MonthlySummaryData(
      year: 2024,
      month: 12,
      totalClimbs: 32,
      completedClimbs: 24,
      lastMonthClimbs: 18,
      monthlyGoal: 30,
      climbingDays: 8,
      totalVideos: 15,
      totalMinutes: 752, // 12시간 32분
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
    final minutes = summaryData.totalMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(summaryData, climbsIncrease),
            const SizedBox(height: 20),

            // 메인 완등 카운트 영역
            _buildMainStats(summaryData, progress),
            const SizedBox(height: 20),

            // 요약 통계 그리드
            _buildQuickStats(summaryData, hours, minutes),
            const SizedBox(height: 16),

            // 가장 많이 방문한 암장
            if (summaryData.mostVisitedGym != null)
              _buildMostVisitedGym(summaryData),
            if (summaryData.mostVisitedGym != null)
              const SizedBox(height: 16),

            // 난이도별 완등 현황
            _buildDifficultyStats(summaryData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MonthlySummaryData data, int climbsIncrease) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00B8D4),
                        Color(0xFF4DD0E1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '이달의 요약',
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '${data.year}년 ${data.month}월',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
        if (climbsIncrease != 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (climbsIncrease > 0 ? AppColors.secondary : AppColors.error)
                      .withOpacity(0.1),
                  (climbsIncrease > 0 ? AppColors.secondary : AppColors.error)
                      .withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  climbsIncrease > 0 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: climbsIncrease > 0 ? AppColors.secondary : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '${climbsIncrease > 0 ? '+' : ''}$climbsIncrease',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: climbsIncrease > 0 ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMainStats(MonthlySummaryData data, double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00B8D4),
            Color(0xFF0097A7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 완등 횟수
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '완등 횟수',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${data.completedClimbs}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '/ ${data.monthlyGoal}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 등반 일수
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data.climbingDays}일',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '등반 일수',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 프로그레스 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '목표 달성률',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt().clamp(0, 100)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(MonthlySummaryData data, int hours, int minutes) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.location_on,
            value: '${data.visitedGymCount}곳',
            label: '암장 방문',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.timer,
            value: '${hours}시간 ${minutes}분',
            label: '총 등반 시간',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostVisitedGym(MonthlySummaryData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 22,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가장 많이 방문한 암장',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.mostVisitedGym!,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${data.mostVisitedGymCount}회',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyStats(MonthlySummaryData data) {
    // 난이도별 색상
    final difficultyColors = {
      'V0-V1': AppColors.success,
      'V2-V3': AppColors.info,
      'V4-V5': AppColors.warning,
      'V6+': AppColors.secondary,
    };

    // 최대값 계산
    final maxCount = data.difficultyStats.values.isEmpty
        ? 1
        : data.difficultyStats.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '난이도별 완등',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (data.maxDifficulty != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withOpacity(0.2),
                      AppColors.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '최고 ${data.maxDifficulty}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.difficultyStats.entries.map((entry) {
          final color = difficultyColors[entry.key] ?? AppColors.textTertiary;
          final progress = maxCount > 0 ? entry.value / maxCount : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    entry.key,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${entry.value}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        // 추가 통계 요약
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMiniStat(
              Icons.videocam,
              '${data.totalVideos}개',
              '영상',
            ),
            Container(
              width: 1,
              height: 24,
              color: AppColors.divider,
            ),
            _buildMiniStat(
              Icons.flag,
              '${data.totalClimbs}회',
              '총 시도',
            ),
            Container(
              width: 1,
              height: 24,
              color: AppColors.divider,
            ),
            _buildMiniStat(
              Icons.percent,
              '${((data.completedClimbs / (data.totalClimbs == 0 ? 1 : data.totalClimbs)) * 100).toInt()}%',
              '완등률',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
