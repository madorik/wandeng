import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 최근 등반 기록 섹션
class RecentClimbRecordSection extends StatelessWidget {
  const RecentClimbRecordSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 데이터로 교체
    final recentRecords = [
      {
        'gymName': '더클라임 연남',
        'difficulty': 'V5',
        'difficultyColor': AppColors.difficultyGradient[3],
        'problemName': '파워풀 루트',
        'isSuccess': true,
        'date': '2시간 전',
        'attempts': 3,
      },
      {
        'gymName': '클라이밍파크 홍대',
        'difficulty': 'V4',
        'difficultyColor': AppColors.difficultyGradient[2],
        'problemName': '슬랩 마스터',
        'isSuccess': true,
        'date': '어제',
        'attempts': 5,
      },
      {
        'gymName': '더클라임 연남',
        'difficulty': 'V6',
        'difficultyColor': AppColors.difficultyGradient[3],
        'problemName': '크랙 챌린지',
        'isSuccess': false,
        'date': '2일 전',
        'attempts': 8,
      },
      {
        'gymName': '볼더링짐 서교',
        'difficulty': 'V3',
        'difficultyColor': AppColors.difficultyGradient[1],
        'problemName': '테크니컬 라인',
        'isSuccess': true,
        'date': '3일 전',
        'attempts': 2,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: recentRecords
            .map((record) => _RecentClimbRecordCard(record: record))
            .toList(),
      ),
    );
  }
}

class _RecentClimbRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _RecentClimbRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isSuccess = record['isSuccess'] as bool;

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
          // 기록 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 완등 상태 도장
              _buildStampIcon(isSuccess),
              const SizedBox(width: 12),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 문제명 & 난이도
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record['problemName'],
                            style: AppTextStyles.labelLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (record['difficultyColor'] as Color)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: record['difficultyColor'] as Color,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            record['difficulty'],
                            style: AppTextStyles.labelSmall.copyWith(
                              color: record['difficultyColor'] as Color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 암장명 & 시도 횟수
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record['gymName'],
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.replay,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${record['attempts']}회 시도',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 시간
              Text(
                record['date'],
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 도장 스타일 아이콘
  Widget _buildStampIcon(bool isSuccess) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSuccess
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.warning,
          width: 2.5,
        ),
      ),
      child: Stack(
        children: [
          // 도장 테두리 효과
          Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isSuccess ? AppColors.success : AppColors.warning)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          // 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSuccess ? '완' : '도',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isSuccess ? AppColors.success : AppColors.warning,
                    height: 1.0,
                  ),
                ),
                Text(
                  isSuccess ? '등' : '전',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isSuccess ? AppColors.success : AppColors.warning,
                    height: 1.0,
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

