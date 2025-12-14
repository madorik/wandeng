import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/video_feed_item.dart';

/// 홈 피드 화면 (틱톡/릴스 스타일)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentPage = 0;

  // 더미 피드 데이터
  final List<Map<String, dynamic>> _feedData = [
    {
      'username': 'climb_master',
      'userImage': 'https://picsum.photos/100/100?random=1',
      'gymName': '더클라임 강남점',
      'sector': 'A섹터',
      'difficulty': 'V4',
      'difficultyColor': AppColors.warning,
      'description': '3주 만에 드디어 완등! 힐훅이 핵심 🔥',
      'likes': 1234,
      'comments': 89,
      'videoColor': Colors.deepPurple,
    },
    {
      'username': 'boulder_girl',
      'userImage': 'https://picsum.photos/100/100?random=2',
      'gymName': '클라이밍파크 홍대',
      'sector': 'B섹터',
      'difficulty': 'V6',
      'difficultyColor': AppColors.secondary,
      'description': '오늘의 도전! 아직 미완등이지만 곧 성공할듯 💪',
      'likes': 2567,
      'comments': 156,
      'videoColor': Colors.teal,
    },
    {
      'username': 'rock_ninja',
      'userImage': 'https://picsum.photos/100/100?random=3',
      'gymName': '피커스 서울숲',
      'sector': 'C섹터',
      'difficulty': 'V3',
      'difficultyColor': AppColors.info,
      'description': '초보자 추천 문제! 재밌어요 😊',
      'likes': 892,
      'comments': 45,
      'videoColor': Colors.indigo,
    },
    {
      'username': 'wall_dancer',
      'userImage': 'https://picsum.photos/100/100?random=4',
      'gymName': '클라이밍 팩토리',
      'sector': 'D섹터',
      'difficulty': 'V5',
      'difficultyColor': AppColors.warning,
      'description': '다이노 무브가 포인트! 발 자신감이 중요 🦶',
      'likes': 3421,
      'comments': 234,
      'videoColor': Colors.deepOrange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 풀스크린 비디오 피드
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _feedData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return VideoFeedItem(data: _feedData[index]);
            },
          ),

          // 상단 오버레이 (로고, 탭, 아이콘)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // 로고
                  Text(
                    '완등',
                    style: AppTextStyles.headline2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  
                  const Spacer(),

                  // 탭: 팔로잉 | 추천
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.overlayDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabButton('팔로잉', 0),
                        _buildTabButton('추천', 1),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 알림 아이콘
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.textPrimary,
                  ),
                  // 검색 아이콘
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),

          // 페이지 인디케이터 (우측)
          Positioned(
            right: 8,
            top: MediaQuery.of(context).size.height / 2 - 40,
            child: Column(
              children: List.generate(_feedData.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: 3,
                  height: _currentPage == index ? 24 : 12,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? AppColors.primary 
                        : AppColors.textSecondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() => _tabController.index = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.background : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

