import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';

class CommentairesSection extends StatefulWidget {
  final int ressourceId;
  const CommentairesSection({super.key, required this.ressourceId});

  @override
  State<CommentairesSection> createState() => _CommentairesSectionState();
}

class _CommentairesSectionState extends State<CommentairesSection> {
  List<Map<String, dynamic>> commentaires = [];
  Map<String, String> auteurs = <String, String>{};
  bool isLoading = true;
  String? error;
  final _commentController = TextEditingController();
  bool _isSending = false;
  String? _sendFeedback;

  // Ajout pour les likes
  Map<int, int> nbLikes = {}; // commentaireID -> nombre de likes
  Set<int> likedCommentaires =
      {}; // IDs des commentaires likés par l'utilisateur
  // Ajout pour les signalements
  Map<int, int> nbReports = {}; // commentaireID -> nombre de signalements
  Set<int> reportedCommentaires =
      {}; // IDs des commentaires signalés par l'utilisateur

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCommentaires();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadLikes(int utilisateurId) async {
    // Récupère le nombre de likes par commentaire et les likes de l'utilisateur
    final commentIds = commentaires.map((c) => c['id'] as int).toList();
    if (commentIds.isEmpty) return;
    // Likes par commentaire
    final likesData = await Supabase.instance.client
        .from('jaimeCommentaire')
        .select('commentaireID')
        .inFilter('commentaireID', commentIds);
    Map<int, int> likeCounts = {};
    for (final c in commentIds) {
      likeCounts[c] = likesData.where((l) => l['commentaireID'] == c).length;
    }
    // Likes de l'utilisateur
    final userLikes = await Supabase.instance.client
        .from('jaimeCommentaire')
        .select('commentaireID')
        .eq('utilisateurID', utilisateurId);
    Set<int> liked =
        userLikes.map<int>((l) => l['commentaireID'] as int).toSet();
    setState(() {
      nbLikes = likeCounts;
      likedCommentaires = liked;
    });
  }

  Future<void> _loadReports(int utilisateurId) async {
    // Récupère le nombre de signalements par commentaire et les signalements de l'utilisateur
    final commentIds = commentaires.map((c) => c['id'] as int).toList();
    if (commentIds.isEmpty) return;
    // Signalements par commentaire
    final reportsData = await Supabase.instance.client
        .from('signalementCommentaire')
        .select('commentaireID')
        .inFilter('commentaireID', commentIds);
    Map<int, int> reportCounts = {};
    for (final c in commentIds) {
      reportCounts[c] =
          reportsData.where((r) => r['commentaireID'] == c).length;
    }
    // Signalements de l'utilisateur
    final userReports = await Supabase.instance.client
        .from('signalementCommentaire')
        .select('commentaireID')
        .eq('utilisateurID', utilisateurId);
    Set<int> reported =
        userReports.map<int>((r) => r['commentaireID'] as int).toSet();
    setState(() {
      nbReports = reportCounts;
      reportedCommentaires = reported;
    });
  }

  Future<void> _likeComment(int commentaireId, int utilisateurId) async {
    await Supabase.instance.client.from('jaimeCommentaire').insert({
      'commentaireID': commentaireId,
      'utilisateurID': utilisateurId,
      'date': DateTime.now().toIso8601String(),
    });
    await _loadLikes(utilisateurId);
  }

  Future<void> _unlikeComment(int commentaireId, int utilisateurId) async {
    await Supabase.instance.client
        .from('jaimeCommentaire')
        .delete()
        .eq('commentaireID', commentaireId)
        .eq('utilisateurID', utilisateurId);
    await _loadLikes(utilisateurId);
  }

  Future<void> _reportComment(int commentaireId, int utilisateurId) async {
    await Supabase.instance.client.from('signalementCommentaire').insert({
      'commentaireID': commentaireId,
      'utilisateurID': utilisateurId,
      'date': DateTime.now().toIso8601String(),
    });
    await _loadReports(utilisateurId);
  }

  Future<void> _loadCommentaires() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Supabase.instance.client
          .from('commentaire')
          .select()
          .eq('ressourceID', widget.ressourceId)
          .order('date', ascending: false);
      final commentairesList = List<Map<String, dynamic>>.from(data);
      final auteurIds = commentairesList
          .map((c) => c['utilisateurID'].toString())
          .toSet()
          .toList();
      Map<String, String> auteursMap = {};
      if (auteurIds.isNotEmpty) {
        final auteursData = await Supabase.instance.client
            .from('utilisateur')
            .select('id, nom, prenom')
            .inFilter('id', auteurIds);
        for (final auteur in auteursData) {
          auteursMap[auteur['id'].toString()] =
              '${auteur['prenom']} ${auteur['nom']}';
        }
        print('DEBUG auteursMap: $auteursMap');
      }
      setState(() {
        commentaires = commentairesList;
        auteurs = auteursMap.map((k, v) => MapEntry(k.toString(), v));
        isLoading = false;
      });
      // Charger les likes si utilisateur connecté
      final currentUser =
          Provider.of<AppAuthState>(context, listen: false).currentUser;
      if (currentUser != null) {
        await _loadLikes(int.parse(currentUser.id));
        await _loadReports(int.parse(currentUser.id));
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AppAuthState>(context).currentUser;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur : $error'));
    }
    if (commentaires.isEmpty) {
      return const Center(
          child: Text('Aucun commentaire pour cette ressource.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < commentaires.length; i++) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auteurs[commentaires[i]['utilisateurID']
                                      .toString()] ??
                                  'Utilisateur inconnu',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              commentaires[i]['date'] != null
                                  ? formatDate(
                                      commentaires[i]['date'].toString())
                                  : '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 4.0),
                    child: Text(
                      commentaires[i]['contenue'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Row(
                    children: [
                      if (currentUser != null) ...[
                        IconButton(
                          icon: Icon(
                            likedCommentaires.contains(commentaires[i]['id'])
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: likedCommentaires
                                    .contains(commentaires[i]['id'])
                                ? Colors.red
                                : null,
                          ),
                          tooltip:
                              likedCommentaires.contains(commentaires[i]['id'])
                                  ? 'Retirer le like'
                                  : 'Liker',
                          onPressed: () async {
                            final commentaireId = commentaires[i]['id'] as int;
                            final utilisateurId = int.parse(currentUser.id);
                            if (likedCommentaires.contains(commentaireId)) {
                              await _unlikeComment(
                                  commentaireId, utilisateurId);
                            } else {
                              await _likeComment(commentaireId, utilisateurId);
                            }
                          },
                        ),
                        Text(nbLikes[commentaires[i]['id']]?.toString() ?? '0'),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            reportedCommentaires.contains(commentaires[i]['id'])
                                ? Icons.flag
                                : Icons.outlined_flag,
                            color: reportedCommentaires
                                    .contains(commentaires[i]['id'])
                                ? Colors.orange
                                : null,
                          ),
                          tooltip: reportedCommentaires
                                  .contains(commentaires[i]['id'])
                              ? 'Déjà signalé'
                              : 'Signaler',
                          onPressed: reportedCommentaires
                                  .contains(commentaires[i]['id'])
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text('Signaler le commentaire'),
                                      content: const Text(
                                          'Voulez-vous vraiment signaler ce commentaire ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Signaler',
                                              style: TextStyle(
                                                  color: Colors.orange)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final commentaireId =
                                        commentaires[i]['id'] as int;
                                    final utilisateurId =
                                        int.parse(currentUser.id);
                                    await _reportComment(
                                        commentaireId, utilisateurId);
                                  }
                                },
                        ),
                        Text(nbReports[commentaires[i]['id']]?.toString() ??
                            '0'),
                        const SizedBox(width: 8),
                        if (commentaires[i]['utilisateurID'].toString() ==
                            currentUser.id)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Supprimer',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Supprimer le commentaire'),
                                  content: const Text(
                                      'Voulez-vous vraiment supprimer ce commentaire ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Supprimer',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await Supabase.instance.client
                                    .from('commentaire')
                                    .delete()
                                    .eq('id', commentaires[i]['id']);
                                await _loadCommentaires();
                              }
                            },
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (i < commentaires.length - 1) const Divider(height: 16),
        ],
        const SizedBox(height: 16),
        if (currentUser != null) ...[
          const Divider(),
          const Text('Ajouter un commentaire',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_sendFeedback != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_sendFeedback!,
                  style: TextStyle(
                      color: _sendFeedback!.contains('envoyé')
                          ? Colors.green
                          : Colors.red)),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Votre commentaire...',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isSending,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _commentController,
                builder: (context, value, child) {
                  final canSend = !_isSending && value.text.trim().isNotEmpty;
                  return IconButton(
                    icon: _isSending
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    color: Colors.blue.shade900,
                    onPressed: canSend
                        ? () async {
                            setState(() {
                              _isSending = true;
                              _sendFeedback = null;
                            });
                            try {
                              await Supabase.instance.client
                                  .from('commentaire')
                                  .insert({
                                'ressourceID': widget.ressourceId,
                                'utilisateurID': int.parse(currentUser.id),
                                'contenue': _commentController.text.trim(),
                                'date': DateTime.now().toIso8601String(),
                                'nbLike': 0,
                                'nbReport': 0,
                                'visible': true,
                              });
                              setState(() {
                                _sendFeedback = 'Commentaire envoyé !';
                                _commentController.clear();
                              });
                              await _loadCommentaires();
                            } catch (e) {
                              setState(() {
                                _sendFeedback = 'Erreur : $e';
                              });
                            } finally {
                              setState(() {
                                _isSending = false;
                              });
                            }
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
