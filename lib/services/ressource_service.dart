import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ressource.dart';

class RessourceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Ressource>> getAllRessources() async {
    final response = await _supabase.from('ressource').select();
    return (response as List)
        .map((json) => Ressource.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ressource>> getRessourcesByUser(int utilisateurId) async {
    final response = await _supabase
        .from('ressource')
        .select()
        .eq('utilisateur_id', utilisateurId);
    return (response as List)
        .map((json) => Ressource.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Ressource> createRessource({
    required String nom,
    required int format,
    required String contenue,
    required String description,
    required int utilisateurId,
    DateTime? date,
  }) async {
    final data = {
      'nom': nom,
      'format': format,
      'contenue': contenue,
      'description': description,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'nbCom': 0,
      'nbLike': 0,
      'nbReport': 0,
      'visible': true,
      'utilisateur_id': utilisateurId,
    };
    final response =
        await _supabase.from('ressource').insert(data).select().single();
    return Ressource.fromJson(response);
  }

  Future<String?> getAuteurNomPrenom(int ressourceId) async {
    // Chercher l'utilisateurID lié à la ressource
    final liaison = await _supabase
        .from('auteur')
        .select('utilisateurID')
        .eq('ressourceID', ressourceId)
        .maybeSingle();
    if (liaison == null || liaison['utilisateurID'] == null) return null;
    final utilisateurId = liaison['utilisateurID'];
    // Chercher le nom et prénom de l'utilisateur
    final utilisateur = await _supabase
        .from('utilisateur')
        .select('nom, prenom')
        .eq('id', utilisateurId)
        .maybeSingle();
    if (utilisateur == null) return null;
    return '${utilisateur['prenom']} ${utilisateur['nom']}';
  }
}
