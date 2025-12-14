import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 비디오 피드 아이템 (틱톡 스타일)
class VideoFeedItem extends StatefulWidget {
  final Map<String, dynamic> data;

  const VideoFeedItem({super.key, required this.data});

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _likeController.forward().then((_) => _likeController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 비디오 배경 (실제로는 VideoPlayer 사용)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (data['videoColor'] as Color).withOpacity(0.8),
                (data['videoColor'] as Color).withOpacity(0.4),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: AppColors.textPrimary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '클라이밍 영상',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 하단 그라데이션
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.bottomFadeGradient,
            ),
          ),
        ),

        // 좌측 하단 정보
        Positioned(
          left: 16,
          bottom: 100,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceLight,
                    backgroundImage: NetworkImage(data['userImage']),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '@${data['username']}',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '팔로우',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 암장 정보
              GestureDetector(
                onTap: () {
                  // 암장 정보 화면으로 이동
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data['gymName']} / ${data['sector']}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    // 난이도 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: data['difficultyColor'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['difficulty'],
                        style: AppTextStyles.difficultyBadge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 설명
              Text(
                data['description'],
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 우측 액션 버튼
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              // 좋아요
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatNumber(data['likes']),
                color: _isLiked ? AppColors.secondary : AppColors.textPrimary,
                onTap: _toggleLike,
                animation: _likeAnimation,
              ),
              const SizedBox(height: 20),

              // 댓글
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(data['comments']),
                onTap: () => _showComments(context),
              ),
              const SizedBox(height: 20),

              // 저장
              _buildActionButton(
                icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: '저장',
                color: _isSaved ? AppColors.primary : AppColors.textPrimary,
                onTap: () => setState(() => _isSaved = !_isSaved),
              ),
              const SizedBox(height: 20),

              // 비교하기
              _buildActionButton(
                icon: Icons.compare_arrows,
                label: '비교',
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // 더보기
              _buildActionButton(
                icon: Icons.more_horiz,
                label: '',
                onTap: () => _showMoreOptions(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = AppColors.textPrimary,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    Widget iconWidget = Icon(icon, size: 32, color: color);
    
    if (animation != null) {
      iconWidget = ScaleTransition(scale: animation, child: iconWidget);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.overlayDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: iconWidget),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ],
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

  void _showComments(BuildContext context) {
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
                // 핸들
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
                    '댓글 ${widget.data['comments']}개',
                    style: AppTextStyles.labelLarge,
                  ),
                ),
                const Divider(color: AppColors.surfaceLight, height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 10,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return _buildCommentItem(index);
                    },
                  ),
                ),
                // 댓글 입력
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceLight,
                        child: Icon(Icons.person, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceLight,
            backgroundImage: NetworkImage(
              'https://picsum.photos/100/100?random=${index + 10}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'user_$index',
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${index + 1}시간 전',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  index % 2 == 0
                      ? '대박! 저도 이 문제 도전 중이에요 💪'
                      : '힐훅 타이밍 어떻게 잡으셨어요?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
                      '${(index + 1) * 5}',
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

  void _showMoreOptions(BuildContext context) {
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
              _buildOptionItem(Icons.share_outlined, '공유하기'),
              _buildOptionItem(Icons.link, '링크 복사'),
              _buildOptionItem(Icons.download_outlined, '저장하기'),
              _buildOptionItem(Icons.flag_outlined, '신고하기'),
              _buildOptionItem(Icons.visibility_off_outlined, '관심없음'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: () => Navigator.pop(context),
    );
  }
}

