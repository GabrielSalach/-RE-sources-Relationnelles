import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileService _profileService;
  late UserProfile _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _profileService = ProfileService(prefs);
    _profile = await _profileService.getProfile();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final imagePath = await _profileService.pickProfileImage();
    if (imagePath != null) {
      setState(() {
        _profile = _profile.copyWith(profileImagePath: imagePath);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _profileService.saveProfile(_profile);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _profileService.deleteAccount();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo de profil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profile.profileImagePath != null
                        ? FileImage(File(_profile.profileImagePath!))
                        : null,
                    child: _profile.profileImagePath == null
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Formulaire
              TextFormField(
                initialValue: _profile.name,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                onChanged: (value) {
                  _profile = _profile.copyWith(name: value);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _profile.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onChanged: (value) {
                  _profile = _profile.copyWith(email: value);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _profile.bio,
                decoration: const InputDecoration(
                  labelText: 'Biographie',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _profile = _profile.copyWith(bio: value);
                },
              ),
              const SizedBox(height: 24),

              // Préférences
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Préférences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Notifications par email'),
                subtitle: const Text('Recevoir des notifications par email'),
                value: _profile.emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _profile = _profile.copyWith(emailNotifications: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le mode sombre'),
                value: _profile.darkMode,
                onChanged: (value) {
                  setState(() {
                    _profile = _profile.copyWith(darkMode: value);
                  });
                },
              ),
              const SizedBox(height: 24),

              // Bouton de suppression du compte
              OutlinedButton(
                onPressed: _deleteAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Supprimer mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
