import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_screen.dart';
import '../../widgets/monthly_summary_card.dart';
import '../../widgets/favorite_gym_card.dart';
import '../../widgets/recent_problem_gym_card.dart';
import '../../widgets/recent_climb_record_card.dart';

/// 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          // 프로필 아이콘
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/a/default-user=s96-c',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이달의 요약
            const MonthlySummaryCard(),
            
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
            onTap: () {
              // 더보기 액션
            },
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
