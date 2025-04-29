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
    // 1. Récupérer les ressourceID de la table auteur
    final liaisonRows = await _supabase
        .from('auteur')
        .select('ressourceID')
        .eq('utilisateurID', utilisateurId);
    if ((liaisonRows as List).isEmpty) return [];
    final ressourceIds =
        (liaisonRows as List).map((row) => row['ressourceID'] as int).toList();
    // 2. Charger les ressources correspondantes
    if (ressourceIds.isEmpty) return [];
    final response =
        await _supabase.from('ressource').select().inFilter('id', ressourceIds);
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

  Future<void> updateNbLike(int ressourceId) async {
    final response = await _supabase
        .from('jaimeRessource')
        .select('id')
        .eq('ressourceID', ressourceId);
    final nbLike = (response as List).length;
    await _supabase
        .from('ressource')
        .update({'nbLike': nbLike}).eq('id', ressourceId);
  }

  Future<void> likeRessource(int ressourceId, int utilisateurId) async {
    await _supabase.from('jaimeRessource').insert({
      'ressourceID': ressourceId,
      'utilisateurID': utilisateurId,
      'date': DateTime.now().toIso8601String(),
    });
    await updateNbLike(ressourceId);
  }

  Future<void> unlikeRessource(int ressourceId, int utilisateurId) async {
    await _supabase
        .from('jaimeRessource')
        .delete()
        .eq('ressourceID', ressourceId)
        .eq('utilisateurID', utilisateurId);
    await updateNbLike(ressourceId);
  }

  Future<void> addFavoris(int ressourceId, int utilisateurId) async {
    await _supabase.from('favoris').insert({
      'ressourceID': ressourceId,
      'utilisateurID': utilisateurId,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavoris(int ressourceId, int utilisateurId) async {
    await _supabase
        .from('favoris')
        .delete()
        .eq('ressourceID', ressourceId)
        .eq('utilisateurID', utilisateurId);
  }

  Future<void> signalerRessource(
      int ressourceId, int utilisateurId, String motif) async {
    // Insérer le signalement
    await _supabase.from('signalementRessource').insert({
      'ressourceID': ressourceId,
      'utilisateurID': utilisateurId,
      'commentaire': motif,
      'date': DateTime.now().toIso8601String(),
      'verifier': false,
    });

    // Incrémenter le compteur de signalements
    await _supabase
        .rpc('increment_report_count', params: {'ressource_id': ressourceId});
  }

  Future<bool> hasLiked(int ressourceId, int utilisateurId) async {
    try {
      final rows = await _supabase
          .from('jaimeRessource')
          .select('id')
          .eq('ressourceID', ressourceId)
          .eq('utilisateurID', utilisateurId);
      print(
          'hasLiked - ressourceId: $ressourceId, utilisateurId: $utilisateurId, result: ${(rows as List).isNotEmpty}');
      return (rows as List).isNotEmpty;
    } catch (e) {
      print('hasLiked - Erreur: $e');
      return false;
    }
  }

  Future<bool> hasFavori(int ressourceId, int utilisateurId) async {
    try {
      final rows = await _supabase
          .from('favoris')
          .select('id')
          .eq('ressourceID', ressourceId)
          .eq('utilisateurID', utilisateurId);
      print(
          'hasFavori - ressourceId: $ressourceId, utilisateurId: $utilisateurId, result: ${(rows as List).isNotEmpty}');
      return (rows as List).isNotEmpty;
    } catch (e) {
      print('hasFavori - Erreur: $e');
      return false;
    }
  }

  Future<bool> hasSignaled(int ressourceId, int utilisateurId) async {
    try {
      final response = await _supabase
          .from('signalementRessource')
          .select()
          .eq('ressourceID', ressourceId)
          .eq('utilisateurID', utilisateurId)
          .maybeSingle();
      print(
          'hasSignaled - ressourceId: $ressourceId, utilisateurId: $utilisateurId, result: ${response != null}');
      return response != null;
    } catch (e) {
      print('hasSignaled - Erreur: $e');
      return false;
    }
  }

  Future<int> fetchNbLike(int ressourceId) async {
    final response = await _supabase
        .from('ressource')
        .select('nbLike')
        .eq('id', ressourceId)
        .single();
    return response['nbLike'] ?? 0;
  }

  Future<List<int>> getFavorisRessourceIds(int utilisateurId) async {
    final rows = await _supabase
        .from('favoris')
        .select('ressourceID')
        .eq('utilisateurID', utilisateurId);
    return (rows as List).map((row) => row['ressourceID'] as int).toList();
  }

  Future<List<Ressource>> getRessourcesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final response =
        await _supabase.from('ressource').select().inFilter('id', ids);
    return (response as List)
        .map((json) => Ressource.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int?> getAuteurUtilisateurId(int ressourceId) async {
    final liaison = await _supabase
        .from('auteur')
        .select('utilisateurID')
        .eq('ressourceID', ressourceId)
        .maybeSingle();
    if (liaison == null || liaison['utilisateurID'] == null) return null;
    return liaison['utilisateurID'] as int;
  }
}
