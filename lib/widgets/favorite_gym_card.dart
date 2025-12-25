import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 자주가는 암장 섹션
class FavoriteGymSection extends StatelessWidget {
  const FavoriteGymSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 데이터로 교체
    final favoriteGyms = [
      {
        'name': '더클라임 연남',
        'visitCount': 12,
        'lastVisit': '2일 전',
        'lastProblemUpdate': '오늘',
        'image': 'https://picsum.photos/seed/gym1/400/300',
      },
      {
        'name': '클라이밍파크 홍대',
        'visitCount': 8,
        'lastVisit': '3일 전',
        'lastProblemUpdate': '어제',
        'image': 'https://picsum.photos/seed/gym2/400/300',
      },
      {
        'name': '볼더링짐 서교',
        'visitCount': 6,
        'lastVisit': '5일 전',
        'lastProblemUpdate': '3일 전',
        'image': 'https://picsum.photos/seed/gym3/400/300',
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: favoriteGyms.length,
        itemBuilder: (context, index) {
          final gym = favoriteGyms[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index < favoriteGyms.length - 1 ? 12 : 0,
            ),
            child: _FavoriteGymCard(gym: gym),
          );
        },
      ),
    );
  }
}

class _FavoriteGymCard extends StatelessWidget {
  final Map<String, dynamic> gym;

  const _FavoriteGymCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: InkWell(
        onTap: () {
          // 암장 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    gym['image'],
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 100,
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 100,
                      color: AppColors.surfaceLight,
                      child: const Icon(
                        Icons.terrain,
                        color: AppColors.textTertiary,
                        size: 40,
                      ),
                    ),
                  ),
                  // 방문 횟수 뱃지
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${gym['visitCount']}회 방문',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym['name'],
                    style: AppTextStyles.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '마지막 방문: ${gym['lastVisit']}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '문제 갱신: ${gym['lastProblemUpdate']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

