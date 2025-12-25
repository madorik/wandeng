import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/gym_card.dart';
import '../profile/profile_screen.dart';

/// 암장 지도 화면
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['영업중', '주차가능', '샤워실', '지구력벽'];
  final Set<String> _selectedFilters = {'영업중'};

  // 더미 암장 데이터
  final List<Map<String, dynamic>> _gyms = [
    {
      'name': '더클라임 강남점',
      'distance': '0.8',
      'crowd': '쾌적',
      'crowdColor': AppColors.crowdLow,
      'newVideos': 12,
      'rating': 4.8,
      'image': 'https://picsum.photos/400/300?random=1',
      'lat': 37.498,
      'lng': 127.028,
    },
    {
      'name': '클라이밍파크 홍대',
      'distance': '2.3',
      'crowd': '보통',
      'crowdColor': AppColors.crowdMedium,
      'newVideos': 8,
      'rating': 4.5,
      'image': 'https://picsum.photos/400/300?random=2',
      'lat': 37.556,
      'lng': 126.923,
    },
    {
      'name': '피커스 서울숲',
      'distance': '3.1',
      'crowd': '혼잡',
      'crowdColor': AppColors.crowdHigh,
      'newVideos': 24,
      'rating': 4.9,
      'image': 'https://picsum.photos/400/300?random=3',
      'lat': 37.544,
      'lng': 127.042,
    },
    {
      'name': '클라이밍 팩토리',
      'distance': '4.5',
      'crowd': '쾌적',
      'crowdColor': AppColors.crowdLow,
      'newVideos': 5,
      'rating': 4.3,
      'image': 'https://picsum.photos/400/300?random=4',
      'lat': 37.512,
      'lng': 127.058,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 지도 영역 (밝은 테마)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFE3F2FD),
                  Color(0xFFF3E5F5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // 그리드 패턴 (지도 느낌)
                CustomPaint(
                  size: Size.infinite,
                  painter: _GridPainter(),
                ),
                
                // 암장 핀들
                ..._gyms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final gym = entry.value;
                  return Positioned(
                    left: 50.0 + (index * 80),
                    top: 150.0 + (index * 60),
                    child: _buildGymPin(gym),
                  );
                }),

                // 현재 위치 표시
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 20,
                  top: MediaQuery.of(context).size.height / 3,
                  child: _buildCurrentLocationMarker(),
                ),
              ],
            ),
          ),

          // 상단 검색바 & 필터
          SafeArea(
            child: Column(
              children: [
                // 검색바 + 프로필
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '암장 이름이나 지역을 검색하세요',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _showFilterSheet(context),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: AppColors.cardShadow,
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
                ),

                // 필터 칩
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilters.contains(filter);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFilters.add(filter);
                              } else {
                                _selectedFilters.remove(filter);
                              }
                            });
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 현재 위치 버튼
          Positioned(
            right: 16,
            bottom: 280,
            child: FloatingActionButton.small(
              heroTag: 'location',
              onPressed: () {},
              backgroundColor: AppColors.background,
              elevation: 4,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // 하단 암장 리스트 (Bottom Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.8,
            snap: true,
            snapSizes: const [0.15, 0.3, 0.8],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // 핸들 및 헤더 (드래그 가능 영역)
                    SliverToBoxAdapter(
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
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  '주변 암장',
                                  style: AppTextStyles.headline3,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_gyms.length}개',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.sort, size: 18),
                                  label: const Text('거리순'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 암장 리스트
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return GymCard(gym: _gyms[index]);
                          },
                          childCount: _gyms.length,
                        ),
                      ),
                    ),
                    // 하단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGymPin(Map<String, dynamic> gym) {
    return GestureDetector(
      onTap: () => _showGymDetail(gym),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gym['crowdColor'] as Color,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (gym['crowdColor'] as Color).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.terrain,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppColors.cardShadowLight,
            ),
            child: Text(
              gym['name'],
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showGymDetail(Map<String, dynamic> gym) {
    // 암장 상세 정보 표시
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('필터', style: AppTextStyles.headline3),
                const SizedBox(height: 24),
                Text('시설', style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filters.map((filter) {
                    return FilterChip(
                      label: Text(filter),
                      selected: _selectedFilters.contains(filter),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFilters.add(filter);
                          } else {
                            _selectedFilters.remove(filter);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('적용하기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 지도 그리드 패턴 페인터
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    
    // 가로선
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // 세로선
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
