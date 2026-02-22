import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database_helper.dart';
import '../../models/gym.dart';
import '../../widgets/gym_card.dart';

/// 암장 지도 화면 (네이버 지도 + GPS + DB)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['주차가능', '샤워실', '지구력벽'];
  final Set<String> _selectedFilters = {};

  NaverMapController? _mapController;
  Position? _currentPosition;
  List<Gym> _filteredGyms = [];

  @override
  void initState() {
    super.initState();
    _loadGyms();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    final gyms = await DatabaseHelper.instance.getAllGyms();
    if (mounted) setState(() => _filteredGyms = gyms);
    _addMarkers();
  }

  Future<void> _applyFilters() async {
    final search = _searchController.text.trim();
    final gyms = await DatabaseHelper.instance.getFilteredGyms(
      search: search.isEmpty ? null : search,
      hasParking: _selectedFilters.contains('주차가능') ? true : null,
      hasShower: _selectedFilters.contains('샤워실') ? true : null,
      hasEnduranceWall: _selectedFilters.contains('지구력벽') ? true : null,
    );
    if (mounted) setState(() => _filteredGyms = gyms);
    _addMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
    }
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String _distanceText(Gym gym) {
    if (_currentPosition == null) return '';
    final d = _distanceKm(
      _currentPosition!.latitude, _currentPosition!.longitude,
      gym.lat, gym.lng,
    );
    return '${d.toStringAsFixed(1)}km';
  }

  void _addMarkers() {
    if (_mapController == null) return;
    _mapController!.clearOverlays();
    final markers = <NMarker>[];
    for (int i = 0; i < _filteredGyms.length; i++) {
      final gym = _filteredGyms[i];
      final marker = NMarker(
        id: 'gym_$i',
        position: NLatLng(gym.lat, gym.lng),
      );
      marker.setOnTapListener((_) => _showGymDetail(gym));
      markers.add(marker);
    }
    _mapController!.addOverlayAll(markers.toSet());
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController?.updateCamera(NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14,
      ));
    } else {
      _mapController?.updateCamera(NCameraUpdate.scrollAndZoomTo(
        target: const NLatLng(37.5665, 126.9780),
        zoom: 12,
      ));
    }
  }

  Color _crowdColor(String? status) {
    switch (status) {
      case '쾌적': return AppColors.crowdLow;
      case '보통': return AppColors.crowdMedium;
      case '혼잡': return AppColors.crowdHigh;
      default: return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedGyms = List<Gym>.from(_filteredGyms);
    if (_currentPosition != null) {
      sortedGyms.sort((a, b) {
        final da = _distanceKm(_currentPosition!.latitude, _currentPosition!.longitude, a.lat, a.lng);
        final db = _distanceKm(_currentPosition!.latitude, _currentPosition!.longitude, b.lat, b.lng);
        return da.compareTo(db);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5665, 126.9780),
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
              if (_currentPosition != null) _moveToCurrentLocation();
            },
          ),

          // 상단 검색바 & 필터
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium,
                      onChanged: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: '암장 이름이나 지역을 검색하세요',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
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
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) { _selectedFilters.add(filter); }
                              else { _selectedFilters.remove(filter); }
                            });
                            _applyFilters();
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
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
              onPressed: () => _getCurrentLocation().then((_) => _moveToCurrentLocation()),
              backgroundColor: AppColors.background,
              elevation: 4,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // 하단 암장 리스트
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text('주변 암장', style: AppTextStyles.headline3),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${sortedGyms.length}개',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final gym = sortedGyms[index];
                            return GymCard(gym: {
                              'name': gym.name,
                              'distance': _distanceText(gym),
                              'crowd': gym.crowdStatus ?? '정보없음',
                              'crowdColor': _crowdColor(gym.crowdStatus),
                              'newVideos': 0,
                              'rating': gym.rating,
                              'image': gym.imageUrl ?? '',
                              'lat': gym.lat,
                              'lng': gym.lng,
                            });
                          },
                          childCount: sortedGyms.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGymDetail(Gym gym) {
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
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surfaceLight,
                      ),
                      child: const Icon(Icons.terrain, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gym.name, style: AppTextStyles.headline3),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[600]),
                              const SizedBox(width: 4),
                              Text('${gym.rating}', style: AppTextStyles.bodySmall),
                              if (_distanceText(gym).isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Text(
                                  _distanceText(gym),
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _crowdColor(gym.crowdStatus).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gym.crowdStatus ?? '정보없음',
                        style: AppTextStyles.labelSmall.copyWith(color: _crowdColor(gym.crowdStatus)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    if (gym.hasParking) _buildFacilityChip('주차', Icons.local_parking),
                    if (gym.hasShower) _buildFacilityChip('샤워', Icons.shower),
                    if (gym.hasEnduranceWall) _buildFacilityChip('지구력벽', Icons.fitness_center),
                  ],
                ),
                const SizedBox(height: 12),
                Text(gym.address, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacilityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
