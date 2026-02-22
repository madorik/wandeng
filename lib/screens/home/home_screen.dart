import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/climb_record_provider.dart';
import '../../widgets/monthly_summary_card.dart';
import '../../widgets/favorite_gym_card.dart';
import '../../widgets/recent_problem_gym_card.dart';
import '../../widgets/recent_climb_record_card.dart';

/// 홈 화면
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final summaryAsync = ref.watch(
      monthlySummaryProvider((year: now.year, month: now.month)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          '완등',
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이달의 요약 — DB 연동
            summaryAsync.when(
              data: (summary) => MonthlySummaryCard(
                data: MonthlySummaryData(
                  year: summary.year,
                  month: summary.month,
                  totalClimbs: summary.totalClimbs,
                  completedClimbs: summary.completedClimbs,
                  climbingDays: summary.climbingDays,
                  totalMinutes: summary.totalMinutes,
                  maxDifficulty: summary.maxDifficulty,
                  difficultyStats: summary.difficultyStats,
                  mostVisitedGym: summary.mostVisitedGym,
                  mostVisitedGymCount: summary.mostVisitedGymCount,
                  visitedGymCount: summary.visitedGymCount,
                ),
              ),
              loading: () => const MonthlySummaryCard(),
              error: (_, __) => const MonthlySummaryCard(),
            ),

            const SizedBox(height: 24),

            // 자주가는 암장
            _buildSectionHeader(context, '자주가는 암장', '더보기'),
            const SizedBox(height: 12),
            const FavoriteGymSection(),

            const SizedBox(height: 24),

            // 최근 문제 갱신한 암장
            _buildSectionHeader(context, '최근 문제 갱신한 암장', '더보기'),
            const SizedBox(height: 12),
            const RecentProblemGymSection(),

            const SizedBox(height: 24),

            // 최근 등반 기록
            _buildSectionHeader(context, '최근 등반 기록', '전체보기'),
            const SizedBox(height: 12),
            const RecentClimbRecordSection(),

            // 하단 네비게이션 바 높이만큼 여백 추가
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headline3,
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              action,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
