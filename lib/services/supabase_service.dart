import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _supabaseClient;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() {
    _supabaseClient = Supabase.instance.client;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'age': userData['age'],
          'bio': userData['bio'],
          'date_naissance': userData['dateDeNaissance'],
          'role': 'user',
          'compte_verif': false,
          'nb_signalement': 0,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      switch (e.statusCode) {
        case '400':
          throw Exception('Email ou mot de passe incorrect');
        case '401':
          throw Exception(
              'Veuillez vérifier votre email avant de vous connecter');
        case '429':
          throw Exception('Trop de tentatives, veuillez réessayer plus tard');
        default:
          throw Exception('Erreur lors de la connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Une erreur inattendue est survenue: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  User? get currentUser => _supabaseClient.auth.currentUser;
}
