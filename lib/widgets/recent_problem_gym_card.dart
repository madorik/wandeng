import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 최근 문제 갱신한 암장 섹션
class RecentProblemGymSection extends StatelessWidget {
  const RecentProblemGymSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 데이터로 교체
    final recentUpdatedGyms = [
      {
        'name': '더클라임 연남',
        'distance': 1.2,
        'updatedDate': '오늘',
        'newProblems': 15,
        'difficulty': 'V0~V7',
        'image': 'https://picsum.photos/seed/gym1/400/300',
      },
      {
        'name': '클라이밍파크 홍대',
        'distance': 2.5,
        'updatedDate': '어제',
        'newProblems': 8,
        'difficulty': 'V2~V5',
        'image': 'https://picsum.photos/seed/gym2/400/300',
      },
      {
        'name': '볼더링짐 서교',
        'distance': 3.1,
        'updatedDate': '3일 전',
        'newProblems': 12,
        'difficulty': 'V0~V6',
        'image': 'https://picsum.photos/seed/gym3/400/300',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: recentUpdatedGyms
            .map((gym) => _RecentProblemGymCard(gym: gym))
            .toList(),
      ),
    );
  }
}

class _RecentProblemGymCard extends StatelessWidget {
  final Map<String, dynamic> gym;

  const _RecentProblemGymCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                gym['image'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 90,
                    height: 90,
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
                  width: 90,
                  height: 90,
                  color: AppColors.surfaceLight,
                  child: const Icon(
                    Icons.terrain,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
                ),
              ),
            ),

            // 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 암장명 & 거리
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gym['name'],
                            style: AppTextStyles.labelLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${gym['distance']}km',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // NEW 뱃지 & 문제 수
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '새 문제 ${gym['newProblems']}개',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 난이도 & 업데이트 시간
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gym['difficulty'],
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.update,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gym['updatedDate'],
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 화살표
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

