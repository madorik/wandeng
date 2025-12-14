import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/crew_card.dart';
import 'crew_create_screen.dart';
import 'crew_detail_screen.dart';

/// 크루 메인 화면
class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 내 크루 더미 데이터
  final List<Map<String, dynamic>> _myCrews = [
    {
      'id': '1',
      'name': '강남 볼더링 크루',
      'image': 'https://picsum.photos/200/200?random=100',
      'memberCount': 24,
      'lastActivity': '방금 전',
      'unreadCount': 5,
      'isAdmin': true,
      'description': '강남 지역 클라이머들의 정기 모임',
      'tags': ['볼더링', '강남', '정기모임'],
    },
    {
      'id': '2',
      'name': 'V6+ 도전 크루',
      'image': 'https://picsum.photos/200/200?random=101',
      'memberCount': 12,
      'lastActivity': '30분 전',
      'unreadCount': 2,
      'isAdmin': false,
      'description': 'V6 이상 문제에 도전하는 중급자 모임',
      'tags': ['V6', '중급자', '챌린지'],
    },
    {
      'id': '3',
      'name': '주말 클라이밍',
      'image': 'https://picsum.photos/200/200?random=102',
      'memberCount': 45,
      'lastActivity': '2시간 전',
      'unreadCount': 0,
      'isAdmin': false,
      'description': '주말마다 함께 등반하는 직장인 모임',
      'tags': ['주말', '직장인', '친목'],
    },
  ];

  // 추천 크루 더미 데이터
  final List<Map<String, dynamic>> _recommendedCrews = [
    {
      'id': '4',
      'name': '초보자 환영 크루',
      'image': 'https://picsum.photos/200/200?random=103',
      'memberCount': 156,
      'description': '클라이밍 처음이신 분들 환영해요!',
      'tags': ['초보자', '환영', '기초'],
      'isJoined': false,
    },
    {
      'id': '5',
      'name': '더클라임 정모',
      'image': 'https://picsum.photos/200/200?random=104',
      'memberCount': 89,
      'description': '더클라임 전 지점 순회 모임',
      'tags': ['더클라임', '정모', '전지점'],
      'isJoined': false,
    },
    {
      'id': '6',
      'name': '클밍 다이어트',
      'image': 'https://picsum.photos/200/200?random=105',
      'memberCount': 234,
      'description': '클라이밍으로 건강하게 다이어트!',
      'tags': ['다이어트', '건강', '운동'],
      'isJoined': false,
    },
    {
      'id': '7',
      'name': '리드 클라이밍 러버',
      'image': 'https://picsum.photos/200/200?random=106',
      'memberCount': 67,
      'description': '리드 클라이밍 전문 크루',
      'tags': ['리드', '전문', '고급'],
      'isJoined': false,
    },
    {
      'id': '8',
      'name': '클라이밍 장비 덕후',
      'image': 'https://picsum.photos/200/200?random=107',
      'memberCount': 128,
      'description': '장비 리뷰 & 공동구매 크루',
      'tags': ['장비', '리뷰', '공구'],
      'isJoined': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    '크루',
                    style: AppTextStyles.headline2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  // 크루 생성 버튼
                  GestureDetector(
                    onTap: () => _navigateToCreateCrew(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.background,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '크루 만들기',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 탭 바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium,
                tabs: const [
                  Tab(text: '내 크루'),
                  Tab(text: '탐색'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyCrewsTab(),
                  _buildExploreTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 내 크루 탭
  Widget _buildMyCrewsTab() {
    if (_myCrews.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myCrews.length,
      itemBuilder: (context, index) {
        final crew = _myCrews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CrewCard(
            data: crew,
            isMyCrewCard: true,
            onTap: () => _navigateToCrewDetail(crew),
          ),
        );
      },
    );
  }

  /// 탐색 탭
  Widget _buildExploreTab() {
    return CustomScrollView(
      slivers: [
        // 검색 바
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                // TODO: 검색 화면으로 이동
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.surfaceLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '크루 이름, 태그로 검색',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // 인기 태그
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('인기 태그', style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTagChip('🔥 인기', true),
                    _buildTagChip('👶 초보자', false),
                    _buildTagChip('💪 고수', false),
                    _buildTagChip('🗓️ 정기모임', false),
                    _buildTagChip('🏢 직장인', false),
                    _buildTagChip('🎓 대학생', false),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // 추천 크루
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('추천 크루', style: AppTextStyles.labelLarge),
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
                    '${_recommendedCrews.length}개',
                    style: AppTextStyles.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // 크루 목록
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final crew = _recommendedCrews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CrewCard(
                    data: crew,
                    isMyCrewCard: false,
                    onTap: () => _navigateToCrewDetail(crew),
                  ),
                );
              },
              childCount: _recommendedCrews.length,
            ),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 가입한 크루가 없어요',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '크루에 가입하거나 새로 만들어보세요!',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '크루 탐색하기',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // TODO: 태그 필터링
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.2) 
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _navigateToCreateCrew() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CrewCreateScreen()),
    );
  }

  void _navigateToCrewDetail(Map<String, dynamic> crew) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CrewDetailScreen(crew: crew)),
    );
  }
}

