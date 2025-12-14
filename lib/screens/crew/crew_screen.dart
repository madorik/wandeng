import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/crew_card.dart';
import '../../widgets/community_post_card.dart';
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

  // 커뮤니티 피드 더미 데이터
  final List<Map<String, dynamic>> _feedPosts = [
    {
      'id': '1',
      'author': '클라이밍초보',
      'authorImage': 'https://picsum.photos/100/100?random=301',
      'content': '오늘 처음으로 V2 완등했어요! 🎉\n너무 뿌듯하네요 ㅎㅎ 다들 응원해주세요~',
      'images': ['https://picsum.photos/400/300?random=401'],
      'likes': 42,
      'comments': 15,
      'createdAt': '10분 전',
      'isLiked': false,
      'tags': ['V2', '완등', '초보'],
    },
    {
      'id': '2',
      'author': '볼더링마스터',
      'authorImage': 'https://picsum.photos/100/100?random=302',
      'content': '더클라임 강남점 오늘 세팅 바뀌었네요!\nV4~V6 구간이 꽤 재밌어요. 추천합니다 👍',
      'images': [
        'https://picsum.photos/400/300?random=402',
        'https://picsum.photos/400/300?random=403',
      ],
      'likes': 128,
      'comments': 34,
      'createdAt': '1시간 전',
      'isLiked': true,
      'tags': ['더클라임', '강남', '세팅'],
    },
    {
      'id': '3',
      'author': '암벽여신',
      'authorImage': 'https://picsum.photos/100/100?random=303',
      'content': '클라이밍 슈즈 추천 부탁드려요!\n발볼 넓은 분들 어떤 슈즈 신으세요? 🤔',
      'images': [],
      'likes': 23,
      'comments': 47,
      'createdAt': '2시간 전',
      'isLiked': false,
      'tags': ['장비', '슈즈', '추천'],
    },
    {
      'id': '4',
      'author': '주말클라이머',
      'authorImage': 'https://picsum.photos/100/100?random=304',
      'content': '홍대 피커스 번개 같이 가실 분!\n이번 주 토요일 오후 2시 예정입니다.\n관심 있으신 분 댓글 남겨주세요~',
      'images': ['https://picsum.photos/400/300?random=404'],
      'likes': 56,
      'comments': 28,
      'createdAt': '3시간 전',
      'isLiked': false,
      'tags': ['번개', '홍대', '피커스'],
    },
    {
      'id': '5',
      'author': '다이노킹',
      'authorImage': 'https://picsum.photos/100/100?random=305',
      'content': '드디어 V6 성공!! 3주 동안 도전했는데 오늘 드디어 해냈어요 💪🔥\n\n핵심은 두번째 홀드에서 힐훅 걸고 밸런스 잡는 거였어요.',
      'images': [
        'https://picsum.photos/400/300?random=405',
        'https://picsum.photos/400/300?random=406',
        'https://picsum.photos/400/300?random=407',
      ],
      'likes': 234,
      'comments': 67,
      'createdAt': '5시간 전',
      'isLiked': true,
      'tags': ['V6', '완등', '힐훅'],
    },
  ];

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
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '크루 만들기',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
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
                color: AppColors.surfaceLight,
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
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium,
                tabs: const [
                  Tab(text: '피드'),
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
                  _buildFeedTab(),
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

  /// 커뮤니티 피드 탭
  Widget _buildFeedTab() {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 인기 태그 (수평 스크롤)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFeedTagChip('🔥 전체', true),
                    _buildFeedTagChip('💬 질문', false),
                    _buildFeedTagChip('🎉 완등', false),
                    _buildFeedTagChip('⚡ 번개', false),
                    _buildFeedTagChip('👟 장비', false),
                    _buildFeedTagChip('📍 암장', false),
                    _buildFeedTagChip('💡 팁', false),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 게시물 목록
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _feedPosts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CommunityPostCard(
                        data: post,
                        onLike: () => _toggleFeedLike(index),
                        onComment: () => _showFeedComments(post),
                        onTap: () => _showPostDetail(post),
                      ),
                    );
                  },
                  childCount: _feedPosts.length,
                ),
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // 글쓰기 FAB
        Positioned(
          right: 16,
          bottom: 20,
          child: GestureDetector(
            onTap: () => _showCreatePostSheet(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedTagChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          // TODO: 태그 필터링
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFeedLike(int index) {
    setState(() {
      _feedPosts[index]['isLiked'] = !_feedPosts[index]['isLiked'];
      if (_feedPosts[index]['isLiked']) {
        _feedPosts[index]['likes']++;
      } else {
        _feedPosts[index]['likes']--;
      }
    });
  }

  void _showFeedComments(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(post: post),
    );
  }

  void _showPostDetail(Map<String, dynamic> post) {
    // TODO: 게시물 상세 화면으로 이동
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text('새 글 작성', style: AppTextStyles.headline3),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: 게시물 등록
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.success),
                                    const SizedBox(width: 8),
                                    Text(
                                      '게시물이 등록되었습니다!',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.textPrimary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('게시', style: AppTextStyles.button),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      maxLines: 5,
                      autofocus: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '클라이밍에 대한 이야기를 공유해보세요...\n#태그를 추가하면 더 많은 사람들이 볼 수 있어요!',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.tag,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
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
              color: AppColors.surfaceLight,
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
            onTap: () => _tabController.animateTo(2),
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
              ? AppColors.primarySoft 
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
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

/// 댓글 시트
class _CommentsSheet extends StatefulWidget {
  final Map<String, dynamic> post;

  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  
  // 더미 댓글 데이터
  final List<Map<String, dynamic>> _comments = [
    {
      'author': '클라이머A',
      'authorImage': 'https://picsum.photos/100/100?random=501',
      'content': '축하해요! 저도 V2 도전 중인데 화이팅이에요 💪',
      'time': '5분 전',
      'likes': 3,
    },
    {
      'author': '볼더링고수',
      'authorImage': 'https://picsum.photos/100/100?random=502',
      'content': '어떤 암장이에요? 저도 가보고 싶네요!',
      'time': '10분 전',
      'likes': 1,
    },
    {
      'author': '클라이밍초보',
      'authorImage': 'https://picsum.photos/100/100?random=503',
      'content': '대단해요~ 저는 아직 V1도 힘든데 ㅎㅎ',
      'time': '15분 전',
      'likes': 5,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
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
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '댓글 ${widget.post['comments']}개',
                  style: AppTextStyles.labelLarge,
                ),
              ),
              
              const Divider(color: AppColors.divider, height: 1),
              
              // 댓글 목록
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(_comments[index]);
                  },
                ),
              ),
              
              // 댓글 입력
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceLight,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '댓글을 입력하세요...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (_commentController.text.trim().isNotEmpty) {
                            setState(() {
                              _comments.insert(0, {
                                'author': '나',
                                'authorImage': 'https://picsum.photos/100/100?random=500',
                                'content': _commentController.text.trim(),
                                'time': '방금 전',
                                'likes': 0,
                              });
                            });
                            _commentController.clear();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceLight,
            backgroundImage: NetworkImage(comment['authorImage'] ?? ''),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['author'] ?? '',
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment['time'] ?? '',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'] ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment['likes']}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '답글',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
