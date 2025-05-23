import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AppAuthState extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AppAuthState() {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final userData = await _supabase
            .from('utilisateur')
            .select()
            .eq('id', session.user.id)
            .single();
        _currentUser = AppUser.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier l'utilisateur dans la table utilisateur
      final response =
          await _supabase.from('utilisateur').select().eq('email', email);

      if (response.isEmpty) {
        throw Exception('Aucun compte trouvé avec cet email');
      }

      final userData = response[0];

      // Vérifier le mot de passe
      if (userData['motDePasse'] != password) {
        throw Exception('Mot de passe incorrect');
      }

      // Créer une session locale
      _currentUser = AppUser.fromJson(userData);
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required DateTime dateNaissance,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _supabase
          .from('utilisateur')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Un compte existe déjà avec cet email');
      }

      // Créer l'utilisateur dans la table utilisateur avec les champs essentiels
      final userData = await _supabase
          .from('utilisateur')
          .insert({
            'email': email,
            'motDePasse': password,
            'nom': nom,
            'prenom': prenom,
            'dateDeNaissance': dateNaissance.toIso8601String(),
            'compteVerif': false,
            'role': 6,
          })
          .select()
          .single();

      _currentUser = AppUser.fromJson(userData);
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
