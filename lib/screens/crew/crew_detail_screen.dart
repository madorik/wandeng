import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/crew_post_card.dart';
import 'crew_chat_screen.dart';

/// 크루 상세 화면
class CrewDetailScreen extends StatefulWidget {
  final Map<String, dynamic> crew;

  const CrewDetailScreen({super.key, required this.crew});

  @override
  State<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

class _CrewDetailScreenState extends State<CrewDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 피드 더미 데이터
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'author': '클라임마스터',
      'authorImage': 'https://picsum.photos/100/100?random=201',
      'content': '오늘 번개 어때요? 저녁 7시에 더클라임 강남점에서 만나요! 🧗‍♂️',
      'images': ['https://picsum.photos/400/300?random=301'],
      'likes': 15,
      'comments': 8,
      'createdAt': '10분 전',
      'isLiked': false,
    },
    {
      'id': '2',
      'author': '볼더걸',
      'authorImage': 'https://picsum.photos/100/100?random=202',
      'content': '지난 주 번개 사진 공유합니다! 다들 수고하셨어요 💪\n다음에도 많이 참여해주세요~',
      'images': [
        'https://picsum.photos/400/300?random=302',
        'https://picsum.photos/400/300?random=303',
      ],
      'likes': 42,
      'comments': 12,
      'createdAt': '3시간 전',
      'isLiked': true,
    },
    {
      'id': '3',
      'author': '록클라이머',
      'authorImage': 'https://picsum.photos/100/100?random=203',
      'content': '신규 회원 환영합니다! 자기소개 부탁드려요 👋',
      'images': [],
      'likes': 28,
      'comments': 15,
      'createdAt': '어제',
      'isLiked': false,
    },
  ];

  // 멤버 더미 데이터
  final List<Map<String, dynamic>> _members = [
    {
      'id': '1',
      'name': '클라임마스터',
      'image': 'https://picsum.photos/100/100?random=201',
      'role': 'admin',
      'level': 'V6',
      'joinedAt': '2024.01.15',
    },
    {
      'id': '2',
      'name': '볼더걸',
      'image': 'https://picsum.photos/100/100?random=202',
      'role': 'moderator',
      'level': 'V5',
      'joinedAt': '2024.02.20',
    },
    {
      'id': '3',
      'name': '록클라이머',
      'image': 'https://picsum.photos/100/100?random=203',
      'role': 'member',
      'level': 'V4',
      'joinedAt': '2024.03.10',
    },
    {
      'id': '4',
      'name': '뉴비클라이머',
      'image': 'https://picsum.photos/100/100?random=204',
      'role': 'member',
      'level': 'V2',
      'joinedAt': '2024.12.01',
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildCrewHeader(),
            _buildTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            _buildChatTab(),
            _buildMembersTab(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showCreatePostSheet(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit, color: AppColors.background),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.overlayDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showCrewSettings(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.overlayDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ),
      ],
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.crew['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceDark,
                  child: const Icon(
                    Icons.group,
                    size: 60,
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewHeader() {
    final tags = widget.crew['tags'] as List<dynamic>? ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 크루명 & 관리자 뱃지
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.crew['name'] ?? '',
                    style: AppTextStyles.headline2,
                  ),
                ),
                if (widget.crew['isAdmin'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '관리자',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 멤버 수 & 활동
            Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.crew['memberCount']}명',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '활동 ${widget.crew['lastActivity'] ?? ''}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 설명
            Text(
              widget.crew['description'] ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.surfaceLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: '피드'),
            Tab(text: '채팅'),
            Tab(text: '멤버'),
          ],
        ),
      ),
    );
  }

  /// 피드 탭
  Widget _buildFeedTab() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 게시물이 없어요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CrewPostCard(
            data: _posts[index],
            onLike: () => _toggleLike(index),
            onComment: () => _showComments(_posts[index]),
          ),
        );
      },
    );
  }

  /// 채팅 탭 (채팅 화면으로 이동 유도)
  Widget _buildChatTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '크루 채팅방',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            '크루원들과 실시간으로 소통해보세요!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _navigateToChat(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat,
                    color: AppColors.background,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '채팅방 입장',
                    style: AppTextStyles.button,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 멤버 탭
  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberItem(member);
      },
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    final role = member['role'] as String;
    final isAdmin = role == 'admin';
    final isModerator = role == 'moderator';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceLight,
                backgroundImage: NetworkImage(member['image'] ?? ''),
              ),
              if (isAdmin || isModerator)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.primary : AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isAdmin ? Icons.star : Icons.verified,
                      size: 10,
                      color: AppColors.background,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // 멤버 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member['name'] ?? '',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(member['level']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member['level'] ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: _getLevelColor(member['level']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '가입일: ${member['joinedAt']}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // 역할 뱃지
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '관리자',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (isModerator)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '운영진',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(String? level) {
    if (level == null) return AppColors.textTertiary;
    
    final levelNum = int.tryParse(level.replaceAll('V', '')) ?? 0;
    if (levelNum <= 2) return AppColors.success;
    if (levelNum <= 4) return AppColors.info;
    if (levelNum <= 6) return AppColors.warning;
    return AppColors.secondary;
  }

  void _toggleLike(int index) {
    setState(() {
      _posts[index]['isLiked'] = !_posts[index]['isLiked'];
      if (_posts[index]['isLiked']) {
        _posts[index]['likes']++;
      } else {
        _posts[index]['likes']--;
      }
    });
  }

  void _showComments(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '댓글 ${post['comments']}개',
                    style: AppTextStyles.labelLarge,
                  ),
                ),
                const Divider(color: AppColors.surfaceLight, height: 1),
                Expanded(
                  child: Center(
                    child: Text(
                      '댓글 기능 준비 중',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
              color: AppColors.surfaceDark,
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
                      color: AppColors.textTertiary,
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
                  const Divider(color: AppColors.surfaceLight, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      maxLines: 5,
                      autofocus: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '크루원들에게 공유하고 싶은 내용을 작성해주세요...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.surfaceLight),
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

  void _showCrewSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.crew['isAdmin'] == true) ...[
                _buildSettingItem(Icons.edit_outlined, '크루 정보 수정'),
                _buildSettingItem(Icons.person_add_outlined, '멤버 관리'),
              ],
              _buildSettingItem(Icons.notifications_outlined, '알림 설정'),
              _buildSettingItem(Icons.share_outlined, '크루 공유'),
              _buildSettingItem(
                Icons.logout,
                '크루 나가기',
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(IconData icon, String label, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.secondary : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDestructive ? AppColors.secondary : AppColors.textPrimary,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  void _navigateToChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CrewChatScreen(crew: widget.crew),
      ),
    );
  }
}

/// TabBar를 SliverPersistentHeader에 고정하기 위한 Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

