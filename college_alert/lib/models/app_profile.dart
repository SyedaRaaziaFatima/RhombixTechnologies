class AppProfile {
  const AppProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.semester,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? department;
  final String? semester;

  bool get isAdmin => role == 'admin';

  factory AppProfile.fromMap(Map<String, dynamic> map) => AppProfile(
        id: map['id'] as String,
        name: (map['name'] as String?)?.trim().isNotEmpty == true
            ? map['name'] as String
            : 'Student',
        email: map['email'] as String? ?? '',
        role: map['role'] as String? ?? 'student',
        department: map['department'] as String?,
        semester: map['semester'] as String?,
      );
}
