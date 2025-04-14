import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _profileImageKey = 'profile_image_path';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _darkModeKey = 'dark_mode';

  final SharedPreferences _prefs;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileService(this._prefs);

  Future<UserProfile> getProfile() async {
    final name = _prefs.getString('name') ?? 'Jean Dupont';
    final email = _prefs.getString('email') ?? 'jean.dupont@example.com';
    final bio =
        _prefs.getString('bio') ?? 'Passionné par les relations humaines';
    final profileImagePath = _prefs.getString(_profileImageKey);
    final emailNotifications = _prefs.getBool(_emailNotificationsKey) ?? true;
    final darkMode = _prefs.getBool(_darkModeKey) ?? false;

    return UserProfile(
      name: name,
      email: email,
      bio: bio,
      profileImagePath: profileImagePath,
      emailNotifications: emailNotifications,
      darkMode: darkMode,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString('name', profile.name);
    await _prefs.setString('email', profile.email);
    await _prefs.setString('bio', profile.bio);
    if (profile.profileImagePath != null) {
      await _prefs.setString(_profileImageKey, profile.profileImagePath!);
    }
    await _prefs.setBool(_emailNotificationsKey, profile.emailNotifications);
    await _prefs.setBool(_darkModeKey, profile.darkMode);
  }

  Future<String?> pickProfileImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    return image?.path;
  }

  Future<void> deleteAccount() async {
    // Supprimer toutes les données liées au profil
    await _prefs.remove('name');
    await _prefs.remove('email');
    await _prefs.remove('bio');
    await _prefs.remove(_profileImageKey);
    await _prefs.remove(_emailNotificationsKey);
    await _prefs.remove(_darkModeKey);

    // TODO: Supprimer la photo de profil du stockage local
  }
}
