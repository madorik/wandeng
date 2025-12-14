import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 크루 생성 화면
class CrewCreateScreen extends StatefulWidget {
  const CrewCreateScreen({super.key});

  @override
  State<CrewCreateScreen> createState() => _CrewCreateScreenState();
}

class _CrewCreateScreenState extends State<CrewCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<String> _selectedTags = [];
  bool _isPrivate = false;
  String? _selectedImage;

  // 추천 태그
  final List<String> _suggestedTags = [
    '볼더링', '리드', '초보자', '중급자', '고급자',
    '정기모임', '주말', '평일', '직장인', '대학생',
    '서울', '강남', '홍대', '신촌', '판교',
    '다이어트', '친목', '챌린지', '대회준비',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
        ),
        title: Text('크루 만들기', style: AppTextStyles.headline3),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _canCreate() ? () => _createCrew() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _canCreate() 
                      ? AppColors.primary 
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '만들기',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _canCreate() 
                          ? AppColors.background 
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 크루 이미지
              _buildImageSection(),
              
              const SizedBox(height: 24),

              // 크루 이름
              _buildSectionTitle('크루 이름', isRequired: true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: '크루 이름을 입력하세요',
                maxLength: 20,
              ),

              const SizedBox(height: 24),

              // 크루 소개
              _buildSectionTitle('크루 소개', isRequired: true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: '크루에 대해 소개해주세요\n(활동 내용, 모임 일정 등)',
                maxLength: 200,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // 태그
              _buildSectionTitle('태그'),
              const SizedBox(height: 8),
              Text(
                '관심사와 맞는 태그를 선택해주세요 (최대 5개)',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 12),
              _buildTagSelector(),

              const SizedBox(height: 24),

              // 공개 설정
              _buildPrivacySetting(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: GestureDetector(
        onTap: () => _selectImage(),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.surfaceLight,
              width: 2,
            ),
            image: _selectedImage != null
                ? DecorationImage(
                    image: NetworkImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '대표 이미지',
                      style: AppTextStyles.caption,
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.overlayDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge,
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLength = 100,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          counterStyle: AppTextStyles.caption,
        ),
      ),
    );
  }

  Widget _buildTagSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 태그
          if (_selectedTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags.map((tag) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTags.remove(tag));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$tag',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.surfaceLight, height: 1),
            const SizedBox(height: 12),
          ],

          // 추천 태그
          Text(
            '추천 태그',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _suggestedTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else if (_selectedTags.length < 5) {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.surfaceLight,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isPrivate 
                      ? AppColors.warning.withOpacity(0.2) 
                      : AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isPrivate ? Icons.lock : Icons.public,
                  size: 20,
                  color: _isPrivate ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPrivate ? '비공개 크루' : '공개 크루',
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      _isPrivate 
                          ? '관리자 승인 후 가입 가능' 
                          : '누구나 자유롭게 가입 가능',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPrivate,
                onChanged: (value) {
                  setState(() => _isPrivate = value);
                },
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.surfaceLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canCreate() {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  void _selectImage() {
    // 임시로 랜덤 이미지 선택
    setState(() {
      _selectedImage = 'https://picsum.photos/200/200?random=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _createCrew() {
    if (!_canCreate()) return;

    // TODO: API 연동하여 크루 생성
    final newCrew = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'tags': _selectedTags,
      'isPrivate': _isPrivate,
      'image': _selectedImage,
    };

    // 성공 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              '${_nameController.text} 크루가 생성되었습니다!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.pop(context, newCrew);
  }
}

