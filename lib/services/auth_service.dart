import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final SupabaseClient _supabaseClient;

  Future<void> initialize() async {
    await dotenv.load();
    _supabaseClient = SupabaseClient(
      dotenv.env['SUPABASE_URL']!,
      dotenv.env['SUPABASE_API_KEY']!,
    );
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  Future<AppUser?> signIn(String email, String password) async {
    try {
      final AuthResponse response =
          await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Aucune session créée');
      }

      final userData = await _supabaseClient
          .from('utilisateurs')
          .select()
          .eq('id', response.user!.id)
          .single();

      return AppUser.fromJson(userData);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String role,
    DateTime? dateNaissance,
    String? adresse,
    String? codePostal,
    String? ville,
    String? telephone,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Aucune session créée');
      }

      final userData = await _supabaseClient
          .from('utilisateurs')
          .insert({
            'id': response.user!.id,
            'email': email,
            'nom': nom,
            'prenom': prenom,
            'role': role,
            'date_naissance': dateNaissance?.toIso8601String(),
            'adresse': adresse,
            'code_postal': codePostal,
            'ville': ville,
            'telephone': telephone,
            'is_verified': false,
          })
          .select()
          .single();

      return AppUser.fromJson(userData);
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        return null;
      }

      final user = session.user;

      final userData = await _supabaseClient
          .from('utilisateurs')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser.fromJson(userData);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }
}
