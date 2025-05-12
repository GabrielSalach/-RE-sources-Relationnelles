import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'ressources-images';
  final _uuid = const Uuid();

  // Télécharger une image
  Future<String> uploadImage(File imageFile) async {
    try {
      final fileExtension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExtension';

      await _supabase.storage.from(_bucketName).upload(fileName, imageFile);

      // Obtenir l'URL publique de l'image
      final imageUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image: $e');
    }
  }

  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final fileName = path.basename(uri.path);

      await _supabase.storage.from(_bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  // Obtenir l'URL publique d'une image
  String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      return _supabase.storage.from(_bucketName).getPublicUrl(imagePath);
    } catch (e) {
      print('Erreur lors de la récupération de l\'URL de l\'image: $e');
      return null;
    }
  }
}
