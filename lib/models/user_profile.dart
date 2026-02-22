/// 사용자 프로필 모델
class UserProfile {
  final int? id;
  final String nickname;
  final int? height;
  final int? wingspan;
  final String? profileImagePath;

  const UserProfile({
    this.id,
    this.nickname = '클라이머',
    this.height,
    this.wingspan,
    this.profileImagePath,
  });

  int? get apeIndex {
    if (height != null && wingspan != null) {
      return wingspan! - height!;
    }
    return null;
  }

  String get apeIndexText {
    final idx = apeIndex;
    if (idx == null) return '-';
    return idx >= 0 ? '+$idx' : '$idx';
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nickname': nickname,
      'height': height,
      'wingspan': wingspan,
      'profile_image_path': profileImagePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      nickname: map['nickname'] as String? ?? '클라이머',
      height: map['height'] as int?,
      wingspan: map['wingspan'] as int?,
      profileImagePath: map['profile_image_path'] as String?,
    );
  }

  UserProfile copyWith({
    int? id,
    String? nickname,
    int? height,
    int? wingspan,
    String? profileImagePath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      height: height ?? this.height,
      wingspan: wingspan ?? this.wingspan,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
