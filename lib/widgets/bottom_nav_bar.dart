import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 홈
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
              ),
              // 지도
              _buildNavItem(
                index: 1,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: '지도',
              ),
              // 중앙 액션 버튼 (촬영하기)
              _buildActionButton(),
              // 크루
              _buildNavItem(
                index: 2,
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: '크루',
              ),
              // 캘린더
              _buildNavItem(
                index: 3,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month,
                label: '캘린더',
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
    required String label,
  }) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
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
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 10,
                ),
                child: Text(label),
              ),
              // 인디케이터
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 2),
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
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: onActionTap,
      child: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.secondaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.videocam,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
