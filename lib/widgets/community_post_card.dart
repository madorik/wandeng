import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 커뮤니티 피드 포스트 카드 위젯 (일반 사용자용)
class CommunityPostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onTap;

  const CommunityPostCard({
    super.key,
    required this.data,
    this.onLike,
    this.onComment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final images = data['images'] as List<dynamic>? ?? [];
    final tags = data['tags'] as List<dynamic>? ?? [];
    final isLiked = data['isLiked'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (프로필, 이름, 시간, 더보기)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceLight,
                    backgroundImage: NetworkImage(data['authorImage'] ?? ''),
                  ),
                  const SizedBox(width: 10),

                  // 이름 & 시간
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['author'] ?? '',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data['createdAt'] ?? '',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 더보기 버튼
                  IconButton(
                    onPressed: () => _showPostOptions(context),
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textSecondary,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // 본문
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                data['content'] ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.5,
                ),
              ),
            ),

            // 태그
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // 이미지
            if (images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageSection(images),
            ],

            // 좋아요 & 댓글 수
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if ((data['likes'] ?? 0) > 0) ...[
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(data['likes'] ?? 0),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if ((data['comments'] ?? 0) > 0)
                    Text(
                      '댓글 ${data['comments']}개',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // 구분선
            Container(
              height: 1,
              color: AppColors.surfaceLight,
            ),

            // 액션 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // 좋아요
                  Expanded(
                    child: _buildActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      label: '좋아요',
                      color: isLiked ? AppColors.secondary : AppColors.textSecondary,
                      onTap: onLike,
                    ),
                  ),

                  // 댓글
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: '댓글',
                      onTap: onComment,
                    ),
                  ),

                  // 공유
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_outlined,
                      label: '공유',
                      onTap: () {
                        // TODO: 공유 기능
                      },
                    ),
                  ),

                  // 저장
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.bookmark_border,
                      label: '저장',
                      onTap: () {
                        // TODO: 저장 기능
                      },
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

  Widget _buildImageSection(List<dynamic> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Image.network(
          images[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppColors.surfaceLight,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            );
          },
        ),
      );
    }

    // 여러 이미지 (그리드)
    if (images.length == 2) {
      return SizedBox(
        height: 180,
        child: Row(
          children: images.map((image) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: images.indexOf(image) == 0 ? 2 : 0,
                  left: images.indexOf(image) == 1 ? 2 : 0,
                ),
                child: Image.network(
                  image,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: AppColors.surfaceLight,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // 3개 이상
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          // 첫 번째 이미지 (큰 것)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Image.network(
                images[0],
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 나머지 이미지들 (세로 스택)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: Image.network(
                      images[1],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, top: 2),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          images.length > 2 ? images[2] : images[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceLight,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        // 추가 이미지 카운트
                        if (images.length > 3)
                          Container(
                            color: AppColors.overlayDark,
                            child: Center(
                              child: Text(
                                '+${images.length - 3}',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = AppColors.textSecondary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }

  void _showPostOptions(BuildContext context) {
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
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: AppColors.textPrimary),
                title: Text('저장하기', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.textPrimary),
                title: Text('링크 복사', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined, color: AppColors.textPrimary),
                title: Text('작성자 팔로우', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.textPrimary),
                title: Text('신고하기', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined, color: AppColors.textPrimary),
                title: Text('관심없음', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

