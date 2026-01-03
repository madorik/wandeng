import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 커스텀 바텀 네비게이션 바
/// 중앙에 플로팅 액션 버튼 스타일의 촬영 버튼 포함
class WandengBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onActionTap;

  const WandengBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // 지도 (index 0 -> MapScreen)
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                ),
              ),
              // 중앙 액션 버튼 (촬영하기)
              _buildActionButton(),
              // 캘린더 (index 1 -> CalendarScreen)
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 28,
                ),
              ),
              // 인디케이터
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 4),
                width: isSelected ? 14 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: onActionTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.videocam_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
