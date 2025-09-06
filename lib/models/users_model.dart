// Model cho profile người dùng và response /users/me
// Tuân thủ cấu trúc JSON đã mô tả trong đề bài

class MeAuth {
  final String id;
  final String email;
  final String username;

  const MeAuth({required this.id, required this.email, required this.username});

  factory MeAuth.fromMap(Map<String, dynamic> map) => MeAuth(
    id: (map['id'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    username: (map['username'] ?? '').toString(),
  );
}

class UserProfile {
  final String? id; // Nếu backend có _id cho document profile
  final String? authId;
  final String? email;
  final String? username;
  final String? phone;
  final String? userClass;
  final String? userSchool;
  final String? address;
  final String? avatar; // URL ảnh
  final DateTime? dateOfBirth;
  final String? gender; // male|female|other

  const UserProfile({
    this.id,
    this.authId,
    this.email,
    this.username,
    this.phone,
    this.userClass,
    this.userSchool,
    this.address,
    this.avatar,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: (map['_id'] ?? map['id'])?.toString(),
    authId: (map['authId'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    username: (map['username'] ?? '').toString(),
    phone: (map['phone'] ?? '').toString(),
    userClass: (map['userClass'] ?? '').toString(),
    userSchool: (map['userSchool'] ?? '').toString(),
    address: (map['address'] ?? '').toString(),
    avatar:
        (map['avatar'] ?? '').toString().isEmpty
            ? null
            : (map['avatar'] as String),
    dateOfBirth:
        map['dateOfBirth'] != null && map['dateOfBirth'].toString().isNotEmpty
            ? DateTime.tryParse(map['dateOfBirth'].toString())
            : null,
    gender:
        (map['gender'] ?? '').toString().isEmpty
            ? null
            : (map['gender'] as String),
  );
}

class MeData {
  final MeAuth auth;
  final UserProfile? profile;

  const MeData({required this.auth, this.profile});

  factory MeData.fromMap(Map<String, dynamic> map) => MeData(
    auth: MeAuth.fromMap(map['auth'] as Map<String, dynamic>? ?? {}),
    profile:
        (map['profile'] == null)
            ? null
            : UserProfile.fromMap(map['profile'] as Map<String, dynamic>),
  );
}

class MeResponse {
  final bool success;
  final String message;
  final MeData data;

  const MeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MeResponse.fromMap(Map<String, dynamic> map) => MeResponse(
    success: map['success'] == true,
    message: (map['message'] ?? '').toString(),
    data: MeData.fromMap(map['data'] as Map<String, dynamic>? ?? {}),
  );
}
