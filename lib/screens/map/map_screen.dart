import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/gym_card.dart';
import '../profile/profile_screen.dart';

/// 암장 지도 화면 (네이버 지도 연동)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['영업중', '주차가능', '샤워실', '지구력벽'];
  final Set<String> _selectedFilters = {'영업중'};
  
  NaverMapController? _mapController;
  
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
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// 지도에 마커 추가
  void _addMarkers() {
    if (_mapController == null) return;
    
    final markers = <NMarker>[];
    for (int i = 0; i < _gyms.length; i++) {
      final gym = _gyms[i];
      final marker = NMarker(
        id: 'gym_$i',
        position: NLatLng(gym['lat'], gym['lng']),
      );
      marker.setOnTapListener((overlay) {
        _showGymDetail(gym);
      });
      markers.add(marker);
    }
    
    _mapController!.addOverlayAll(markers.toSet());
  }

  /// 현재 위치로 이동
  void _moveToCurrentLocation() {
    _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: const NLatLng(37.5665, 126.9780), // 서울시청 (기본 위치)
        zoom: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 네이버 지도
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5665, 126.9780), // 서울시청
                zoom: 12,
              ),
              mapType: NMapType.basic,
              activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
              rotationGesturesEnable: true,
              scrollGesturesEnable: true,
              tiltGesturesEnable: true,
              zoomGesturesEnable: true,
              locationButtonEnable: false,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _addMarkers();
            },
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
              onPressed: _moveToCurrentLocation,
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
                      child: SizedBox(height: 100),
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

  void _showGymDetail(Map<String, dynamic> gym) {
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
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(gym['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gym['name'], style: AppTextStyles.headline3),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${gym['rating']}',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${gym['distance']}km',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (gym['crowdColor'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gym['crowd'],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: gym['crowdColor'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 암장 상세 화면으로 이동
                    },
                    child: const Text('암장 상세보기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
