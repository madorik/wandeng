import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 크루 피드 포스트 카드 위젯
class CrewPostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const CrewPostCard({
    super.key,
    required this.data,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final images = data['images'] as List<dynamic>? ?? [];
    final isLiked = data['isLiked'] as bool? ?? false;

    return Container(
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
            padding: const EdgeInsets.all(12),
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
                        style: AppTextStyles.labelMedium,
                      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              data['content'] ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
          ),

          // 이미지
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImageSection(images),
          ],

          // 좋아요 & 댓글 수
          Padding(
            padding: const EdgeInsets.all(12),
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
                    '${data['likes']}',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(List<dynamic> images) {
    if (images.length == 1) {
      return ClipRRect(
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
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < images.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 160,
                    height: 160,
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
        },
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
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
                leading: const Icon(Icons.flag_outlined, color: AppColors.textPrimary),
                title: Text('신고하기', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined, color: AppColors.textPrimary),
                title: Text('숨기기', style: AppTextStyles.bodyMedium),
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

