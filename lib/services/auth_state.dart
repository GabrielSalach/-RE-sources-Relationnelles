import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AppAuthState extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _currentUser;
  bool _isLoading = false;

  AppAuthState() {
    _currentUser = _supabaseService.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabaseService.signIn(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabaseService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
