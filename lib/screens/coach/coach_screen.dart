import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// AI 코치 화면
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  // 분석된 영상 더미 데이터
  final List<Map<String, dynamic>> _analyzedVideos = [
    {
      'title': '더클라임 V4 완등',
      'date': '2024.12.14',
      'score': 85,
      'thumbnail': 'https://picsum.photos/200/300?random=1',
      'issues': 2,
    },
    {
      'title': '피커스 V5 도전',
      'date': '2024.12.13',
      'score': 72,
      'thumbnail': 'https://picsum.photos/200/300?random=2',
      'issues': 3,
    },
    {
      'title': '홍대 V3 연습',
      'date': '2024.12.12',
      'score': 91,
      'thumbnail': 'https://picsum.photos/200/300?random=3',
      'issues': 1,
    },
    {
      'title': '강남 V6 실패',
      'date': '2024.12.11',
      'score': 58,
      'thumbnail': 'https://picsum.photos/200/300?random=4',
      'issues': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AI 코치',
                          style: AppTextStyles.headline2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이번 주 분석 리포트',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 스타일 분석 카드 (레이더 차트)
            SliverToBoxAdapter(
              child: _buildStyleAnalysisCard(),
            ),

            // 피드백 요약
            SliverToBoxAdapter(
              child: _buildFeedbackSummary(),
            ),

            // 분석된 영상 리스트 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Text('분석 완료된 영상', style: AppTextStyles.headline3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_analyzedVideos.length}개',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 분석된 영상 리스트
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildVideoAnalysisCard(_analyzedVideos[index]);
                  },
                  childCount: _analyzedVideos.length,
                ),
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleAnalysisCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '나의 등반 스타일',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 레이더 차트
          SizedBox(
            height: 200,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withOpacity(0.2),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: const [
                      RadarEntry(value: 4.5),  // 유연성
                      RadarEntry(value: 3.8),  // 파워
                      RadarEntry(value: 2.5),  // 밸런스
                      RadarEntry(value: 4.2),  // 속도
                      RadarEntry(value: 3.5),  // 정확도
                    ],
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                radarBorderData: const BorderSide(
                  color: AppColors.surfaceLight,
                  width: 1,
                ),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 10,
                ),
                tickBorderData: const BorderSide(
                  color: AppColors.surfaceLight,
                  width: 0.5,
                ),
                gridBorderData: const BorderSide(
                  color: AppColors.surfaceLight,
                  width: 0.5,
                ),
                getTitle: (index, angle) {
                  const titles = ['유연성', '파워', '밸런스', '속도', '정확도'];
                  return RadarChartTitle(
                    text: titles[index],
                    angle: 0,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '이번 주 코칭 포인트',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '회원님은 다이내믹한 무브에 강하지만, 정적인 밸런스가 약해요. 이번 주에는 슬로우 클라이밍에 집중해보세요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.trending_up,
                label: '강점',
                value: '속도, 유연성',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.trending_down,
                label: '약점',
                value: '밸런스',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoAnalysisCard(Map<String, dynamic> video) {
    final scoreColor = video['score'] >= 80
        ? AppColors.success
        : video['score'] >= 60
            ? AppColors.warning
            : AppColors.secondary;

    return GestureDetector(
      onTap: () => _showVideoAnalysisDetail(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 썸네일
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: Image.network(
                    video['thumbnail'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
                // 점수 뱃지
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${video['score']}점',
                      style: AppTextStyles.difficultyBadge,
                    ),
                  ),
                ),
              ],
            ),

            // 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: AppTextStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['date'],
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '개선점 ${video['issues']}개',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 화살표
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoAnalysisDetail(Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VideoAnalysisDetailSheet(video: video),
    );
  }
}

/// 영상 분석 상세 시트
class _VideoAnalysisDetailSheet extends StatelessWidget {
  final Map<String, dynamic> video;

  const _VideoAnalysisDetailSheet({required this.video});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Text(
                        video['title'],
                        style: AppTextStyles.headline3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                    ),
                  ],
                ),
              ),

              // 영상 재생 영역 (스켈레톤 오버레이 포함)
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // 영상 (더미)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '스켈레톤 오버레이 적용됨',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),

                    // 타임라인 바
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // 진행 바
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.textTertiary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // 문제 구간 표시
                              Positioned(
                                left: 50,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 120,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0:00', style: AppTextStyles.caption),
                              Text('1:32', style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 코칭 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      '코칭 포인트',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildCoachingPoint(
                      time: '0:15',
                      title: '무게중심 이동',
                      description: '여기서 무게중심이 뒤로 빠졌어요. 벽 쪽으로 엉덩이를 5cm 더 붙이세요.',
                      color: AppColors.secondary,
                    ),
                    _buildCoachingPoint(
                      time: '0:42',
                      title: '발 위치 조정',
                      description: '오른발을 홀드 끝에 걸면 더 안정적으로 이동할 수 있어요.',
                      color: AppColors.warning,
                    ),
                    _buildCoachingPoint(
                      time: '1:05',
                      title: '호흡 타이밍',
                      description: '다이노 전에 숨을 들이마시고, 점프하면서 내쉬세요.',
                      color: AppColors.info,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoachingPoint({
    required String time,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time,
                  style: AppTextStyles.difficultyBadge,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

