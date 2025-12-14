import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 마이페이지 (프로필) 화면
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 더미 데이터
  final List<Map<String, dynamic>> _myVideos = List.generate(
    12,
    (index) => {
      'thumbnail': 'https://picsum.photos/200/300?random=${index + 20}',
      'difficulty': 'V${(index % 7) + 1}',
      'views': (index + 1) * 123,
    },
  );

  final List<Map<String, dynamic>> _savedBetas = List.generate(
    8,
    (index) => {
      'thumbnail': 'https://picsum.photos/200/300?random=${index + 40}',
      'gym': '암장 ${index + 1}',
      'difficulty': 'V${(index % 5) + 2}',
    },
  );

  final List<Map<String, dynamic>> _visitedGyms = [
    {'name': '더클라임 강남', 'color': AppColors.primary},
    {'name': '피커스 서울숲', 'color': AppColors.info},
    {'name': '클라이밍파크', 'color': AppColors.secondary},
    {'name': '볼더프렌즈', 'color': AppColors.warning},
    {'name': '클라임존', 'color': AppColors.success},
    {'name': '락클라이밍', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 프로필 헤더
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),

            // 통계 카드들
            SliverToBoxAdapter(
              child: _buildStatisticsSection(),
            ),

            // 탭바
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '내 영상'),
                    Tab(text: '저장한 베타'),
                    Tab(text: '성장 기록'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.labelLarge,
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyVideosTab(),
            _buildSavedBetasTab(),
            _buildGrowthTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 상단 액션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '마이페이지',
                  style: AppTextStyles.headline2,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 프로필 정보
            Row(
              children: [
                // 프로필 사진
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://picsum.photos/200/200?random=100',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // 이름 & 칭호
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '클라임마스터',
                            style: AppTextStyles.headline3,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.secondary.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🕷️ 강남 스파이더맨',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 신체 스펙
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
                boxShadow: AppColors.cardShadowLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSpecItem('신장', '175cm'),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  _buildSpecItem('윙스팬', '180cm'),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider,
                  ),
                  _buildSpecItem('에이프 인덱스', '+5'),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
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

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Climb Passport
          _buildPassportCard(),
          const SizedBox(height: 16),

          // Level Badge
          _buildLevelBadge(),
          const SizedBox(height: 16),

          // 통계 요약
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.videocam,
                  value: '${_myVideos.length}',
                  label: '업로드',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite,
                  value: '2.4K',
                  label: '받은 좋아요',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  value: '156',
                  label: '팔로워',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceLight,
            AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_membership,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Climb Passport',
                style: AppTextStyles.labelLarge,
              ),
              const Spacer(),
              Text(
                '${_visitedGyms.length}곳 방문',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 암장 스탬프
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._visitedGyms.map((gym) => _buildStamp(gym)),
              // 빈 스탬프들
              ...List.generate(4, (_) => _buildEmptyStamp()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStamp(Map<String, dynamic> gym) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: (gym['color'] as Color).withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: gym['color'] as Color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          (gym['name'] as String).substring(0, 2),
          style: AppTextStyles.labelSmall.copyWith(
            color: gym['color'] as Color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStamp() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.divider,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.15),
            AppColors.secondarySoft,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'V5',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최고 완등 난이도',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  '중급 클라이머',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'V6까지 2개 남음!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: AppColors.warning,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.numberMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildMyVideosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: _myVideos.length,
      itemBuilder: (context, index) {
        final video = _myVideos[index];
        return _buildVideoThumbnail(video);
      },
    );
  }

  Widget _buildVideoThumbnail(Map<String, dynamic> video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            video['thumbnail'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceLight,
                child: const Icon(
                  Icons.videocam,
                  color: AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
        // 난이도 뱃지
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              video['difficulty'],
              style: AppTextStyles.difficultyBadge.copyWith(
                fontSize: 10,
              ),
            ),
          ),
        ),
        // 조회수
        Positioned(
          bottom: 8,
          left: 8,
          child: Row(
            children: [
              const Icon(
                Icons.play_arrow,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 2),
              Text(
                '${video['views']}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedBetasTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _savedBetas.length,
      itemBuilder: (context, index) {
        final beta = _savedBetas[index];
        return _buildBetaCard(beta);
      },
    );
  }

  Widget _buildBetaCard(Map<String, dynamic> beta) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    beta['thumbnail'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.bookmark,
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  ),
                  // 저장 아이콘
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beta['gym'],
                  style: AppTextStyles.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    beta['difficulty'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월별 완등 그래프
          Text('월별 완등 수', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['7월', '8월', '9월', '10월', '11월', '12월'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[value.toInt()],
                            style: AppTextStyles.caption,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 12),
                  _makeGroupData(1, 18),
                  _makeGroupData(2, 15),
                  _makeGroupData(3, 22),
                  _makeGroupData(4, 25),
                  _makeGroupData(5, 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 난이도별 완등 현황
          Text('난이도별 완등', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: Column(
              children: [
                _buildDifficultyProgress('V0-V1', 0.95, AppColors.success),
                _buildDifficultyProgress('V2-V3', 0.85, AppColors.info),
                _buildDifficultyProgress('V4-V5', 0.60, AppColors.warning),
                _buildDifficultyProgress('V6-V7', 0.25, AppColors.secondary),
                _buildDifficultyProgress('V8+', 0.05, Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.6),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyProgress(
    String label,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.labelSmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// 탭바 고정용 Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
