import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 크루 채팅 화면
class CrewChatScreen extends StatefulWidget {
  final Map<String, dynamic> crew;

  const CrewChatScreen({super.key, required this.crew});

  @override
  State<CrewChatScreen> createState() => _CrewChatScreenState();
}

class _CrewChatScreenState extends State<CrewChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  // 더미 메시지 데이터
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'sender': '클라임마스터',
      'senderImage': 'https://picsum.photos/100/100?random=201',
      'content': '안녕하세요! 오늘 저녁 7시에 모임 있습니다 👋',
      'time': '오후 2:30',
      'isMe': false,
    },
    {
      'id': '2',
      'sender': '나',
      'senderImage': 'https://picsum.photos/100/100?random=200',
      'content': '네 참석할게요!',
      'time': '오후 2:32',
      'isMe': true,
    },
    {
      'id': '3',
      'sender': '볼더걸',
      'senderImage': 'https://picsum.photos/100/100?random=202',
      'content': '저도요~ 오늘 더클라임이죠?',
      'time': '오후 2:35',
      'isMe': false,
    },
    {
      'id': '4',
      'sender': '클라임마스터',
      'senderImage': 'https://picsum.photos/100/100?random=201',
      'content': '네 맞아요! 더클라임 강남점입니다 🧗‍♂️\n주소는 카카오맵에 공유할게요',
      'time': '오후 2:36',
      'isMe': false,
    },
    {
      'id': '5',
      'sender': '록클라이머',
      'senderImage': 'https://picsum.photos/100/100?random=203',
      'content': '혹시 장비 빌릴 수 있나요?',
      'time': '오후 3:00',
      'isMe': false,
    },
    {
      'id': '6',
      'sender': '클라임마스터',
      'senderImage': 'https://picsum.photos/100/100?random=201',
      'content': '암장에서 대여 가능해요! 처음 오시는 분들은 대여로 하시면 됩니다 👍',
      'time': '오후 3:02',
      'isMe': false,
    },
    {
      'id': '7',
      'sender': '나',
      'senderImage': 'https://picsum.photos/100/100?random=200',
      'content': '저 오늘 V5 도전해볼게요 💪',
      'time': '오후 3:10',
      'isMe': true,
    },
    {
      'id': '8',
      'sender': '볼더걸',
      'senderImage': 'https://picsum.photos/100/100?random=202',
      'content': '오 대박! 응원해요~ 😊',
      'time': '오후 3:11',
      'isMe': false,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.crew['image'] ?? '',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    color: AppColors.surfaceLight,
                    child: const Icon(Icons.group, size: 18),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.crew['name'] ?? '',
                    style: AppTextStyles.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.crew['memberCount']}명 참여중',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showChatMenu(),
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showSender = index == 0 ||
                    _messages[index - 1]['sender'] != message['sender'];
                
                return _buildMessageBubble(message, showSender);
              },
            ),
          ),

          // 메시지 입력
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool showSender) {
    final isMe = message['isMe'] as bool;

    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 16 : 4,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // 프로필 이미지 (다른 사람 메시지일 때)
          if (!isMe && showSender)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceLight,
                backgroundImage: NetworkImage(message['senderImage'] ?? ''),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 40),

          // 메시지 내용
          Flexible(
            child: Column(
              crossAxisAlignment: 
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 발신자 이름 (다른 사람 메시지일 때)
                if (!isMe && showSender)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message['sender'] ?? '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                // 메시지 버블
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 시간 (내 메시지일 때 왼쪽)
                    if (isMe) ...[
                      Text(
                        message['time'] ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // 메시지 버블
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe 
                              ? AppColors.primary 
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                          border: isMe 
                              ? null 
                              : Border.all(
                                  color: AppColors.surfaceLight,
                                  width: 1,
                                ),
                        ),
                        child: Text(
                          message['content'] ?? '',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isMe 
                                ? AppColors.background 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    // 시간 (다른 사람 메시지일 때 오른쪽)
                    if (!isMe) ...[
                      const SizedBox(width: 6),
                      Text(
                        message['time'] ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 추가 버튼
            IconButton(
              onPressed: () => _showAttachmentOptions(),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.textSecondary,
              ),
            ),

            // 텍스트 입력
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.surfaceLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: AppTextStyles.bodyMedium,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 전송 버튼
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColors.background,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'sender': '나',
        'senderImage': 'https://picsum.photos/100/100?random=200',
        'content': text,
        'time': _formatTime(DateTime.now()),
        'isMe': true,
      });
    });

    _messageController.clear();

    // 스크롤 맨 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$period $displayHour:$minute';
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      Icons.image,
                      '사진',
                      AppColors.info,
                    ),
                    _buildAttachmentOption(
                      Icons.camera_alt,
                      '카메라',
                      AppColors.success,
                    ),
                    _buildAttachmentOption(
                      Icons.location_on,
                      '위치',
                      AppColors.warning,
                    ),
                    _buildAttachmentOption(
                      Icons.event,
                      '일정',
                      AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // TODO: 각 옵션 처리
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
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
                leading: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                title: Text('알림 설정', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.search, color: AppColors.textPrimary),
                title: Text('메시지 검색', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.people_outline, color: AppColors.textPrimary),
                title: Text('참여자 목록', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.secondary),
                title: Text(
                  '채팅방 나가기',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
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

