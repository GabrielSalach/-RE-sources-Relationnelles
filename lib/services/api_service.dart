import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/resource.dart';

class ApiService {
  static const String _apiPath = '/rest/v1';
  final http.Client _client;
  String? _apiKey;
  String? _baseUrl;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> _ensureApiKey() async {
    if (_apiKey == null || _baseUrl == null) {
      await dotenv.load();
      _apiKey = dotenv.env['SUPABASE_API_KEY'];
      _baseUrl = dotenv.env['SUPABASE_URL'];
    }
  }

  String get _fullBaseUrl => '$_baseUrl$_apiPath';

  Map<String, String> get _headers => {
    'apikey': _apiKey!,
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // Récupérer toutes les ressources
  Future<List<Resource>> getResources() async {
    try {
      await _ensureApiKey();
      final response = await _client.get(
        Uri.parse('$_fullBaseUrl/ressource'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('Données reçues de Supabase: $jsonList');
        return jsonList.map((json) => Resource.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des ressources: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Erreur détaillée: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer une ressource par ID
  Future<Resource> getResourceById(String id) async {
    try {
      await _ensureApiKey();
      final response = await _client.get(
        Uri.parse('$_fullBaseUrl/ressource?id=eq.$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) {
          throw Exception('Ressource non trouvée');
        }
        return Resource.fromJson(jsonList.first);
      } else {
        throw Exception(
          'Erreur lors de la récupération de la ressource: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Créer une nouvelle ressource
  Future<Resource> createResource(Resource resource) async {
    try {
      await _ensureApiKey();
      final response = await _client.post(
        Uri.parse('$_fullBaseUrl/ressource'),
        headers: _headers,
        body: json.encode(resource.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);
        return Resource.fromJson(jsonList.first);
      } else {
        throw Exception(
          'Erreur lors de la création de la ressource: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour une ressource
  Future<Resource> updateResource(String id, Resource resource) async {
    try {
      await _ensureApiKey();
      final response = await _client.patch(
        Uri.parse('$_fullBaseUrl/ressource?id=eq.$id'),
        headers: _headers,
        body: json.encode(resource.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return Resource.fromJson(jsonList.first);
      } else {
        throw Exception(
          'Erreur lors de la mise à jour de la ressource: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer une ressource
  Future<void> deleteResource(String id) async {
    try {
      await _ensureApiKey();
      final response = await _client.delete(
        Uri.parse('$_fullBaseUrl/ressource?id=eq.$id'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Erreur lors de la suppression de la ressource: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les ressources par format
  Future<List<Resource>> getResourcesByFormat(String format) async {
    try {
      await _ensureApiKey();
      final response = await _client.get(
        Uri.parse('$_fullBaseUrl/ressource?format=eq.$format'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Resource.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des ressources par format: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
