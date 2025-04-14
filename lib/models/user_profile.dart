class UserProfile {
  final String name;
  final String email;
  final String bio;
  final String? profileImagePath;
  final bool emailNotifications;
  final bool darkMode;

  UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    this.profileImagePath,
    this.emailNotifications = true,
    this.darkMode = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? profileImagePath,
    bool? emailNotifications,
    bool? darkMode,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
