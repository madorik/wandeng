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

/// 이달의 요약 카드 위젯
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
    final minutes = summaryData.totalMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // 헤더 섹션
          _buildHeader(summaryData, climbsIncrease),

          // 메인 통계 섹션
          _buildMainStats(summaryData, progress),

          // 퀵 통계 섹션
          _buildQuickStats(summaryData, hours, minutes),

          // 가장 많이 방문한 암장
          if (summaryData.mostVisitedGym != null)
            _buildMostVisitedGym(summaryData),

          // 난이도별 완등
          _buildDifficultySection(summaryData),

          // 하단 미니 통계
          _buildBottomStats(summaryData),
        ],
      ),
    );
  }

  Widget _buildHeader(MonthlySummaryData data, int climbsIncrease) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이달의 요약',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.year}년 ${data.month}월',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          if (climbsIncrease != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: climbsIncrease > 0
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    climbsIncrease > 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: climbsIncrease > 0 ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${climbsIncrease > 0 ? '+' : ''}$climbsIncrease',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: climbsIncrease > 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainStats(MonthlySummaryData data, double progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 완등 횟수
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '완등',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${data.completedClimbs}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${data.monthlyGoal}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 등반 일수
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${data.climbingDays}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '등반일',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 프로그레스 바
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이번 달 목표',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt().clamp(0, 100)}%',
                    style: const TextStyle(
                      fontSize: 12,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.location_on_outlined,
              value: '${data.visitedGymCount}',
              unit: '곳',
              label: '암장 방문',
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.schedule_outlined,
              value: '$hours',
              unit: '시간 ${minutes}분',
              label: '총 등반 시간',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostVisitedGym(MonthlySummaryData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '가장 많이 방문',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.mostVisitedGym!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildDifficultySection(MonthlySummaryData data) {
    final difficultyColors = [
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.secondary,
    ];

    final maxCount = data.difficultyStats.values.isEmpty
        ? 1
        : data.difficultyStats.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '난이도별 완등',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (data.maxDifficulty != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.keyboard_double_arrow_up_rounded,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '최고 ${data.maxDifficulty}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...data.difficultyStats.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = difficultyColors[index % difficultyColors.length];
            final progressValue = maxCount > 0 ? item.value / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.key,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 16,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${item.value}',
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
        ],
      ),
    );
  }

  Widget _buildBottomStats(MonthlySummaryData data) {
    final completionRate = data.totalClimbs > 0
        ? ((data.completedClimbs / data.totalClimbs) * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomStatItem(
              icon: Icons.videocam_outlined,
              value: '${data.totalVideos}',
              label: '영상',
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.divider),
          Expanded(
            child: _BottomStatItem(
              icon: Icons.flag_outlined,
              value: '${data.totalClimbs}',
              label: '시도',
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.divider),
          Expanded(
            child: _BottomStatItem(
              icon: Icons.check_circle_outline,
              value: '$completionRate%',
              label: '완등률',
            ),
          ),
        ],
      ),
    );
  }
}

/// 퀵 통계 아이템 위젯
class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.numberMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        unit,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
}

/// 하단 통계 아이템 위젯
class _BottomStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _BottomStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
