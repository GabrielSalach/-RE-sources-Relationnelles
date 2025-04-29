import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';

class ModerationCommentairesPage extends StatefulWidget {
  const ModerationCommentairesPage({Key? key}) : super(key: key);

  @override
  State<ModerationCommentairesPage> createState() =>
      _ModerationCommentairesPageState();
}

class _ModerationCommentairesPageState
    extends State<ModerationCommentairesPage> {
  List<Map<String, dynamic>> commentaires = [];
  Map<String, String> auteurs = {};
  Map<int, int> nbSignalements = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCommentairesSignales();
  }

  Future<void> _loadCommentairesSignales() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Récupérer tous les commentaires signalés (présents dans signalementCommentaire)
      final signaled = await Supabase.instance.client
          .from('signalementCommentaire')
          .select('commentaireID');
      final ids =
          signaled.map((e) => e['commentaireID'] as int).toSet().toList();
      if (ids.isEmpty) {
        setState(() {
          commentaires = [];
          isLoading = false;
        });
        return;
      }
      // Récupérer les commentaires concernés avec leurs ressources
      final data = await Supabase.instance.client.from('commentaire').select('''
            *,
            ressource:ressourceID(id, nom, description, contenue, format)
          ''').inFilter('id', ids).order('date', ascending: false);
      final commentairesList = List<Map<String, dynamic>>.from(data);
      // Récupérer les auteurs
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
      }
      // Compter les signalements par commentaire
      Map<int, int> nbSign = {};
      for (final id in ids) {
        nbSign[id] = signaled.where((e) => e['commentaireID'] == id).length;
      }
      setState(() {
        commentaires = commentairesList;
        auteurs = auteursMap;
        nbSignalements = nbSign;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _setVisible(int commentaireId, bool visible) async {
    await Supabase.instance.client
        .from('commentaire')
        .update({'visible': visible}).eq('id', commentaireId);
    await _loadCommentairesSignales();
  }

  Future<void> _deleteComment(int commentaireId) async {
    await Supabase.instance.client
        .from('commentaire')
        .delete()
        .eq('id', commentaireId);
    await _loadCommentairesSignales();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AppAuthState>(context).currentUser;
    // Vérification du rôle
    final allowedRoles = ['1', '2', '3'];
    if (currentUser == null || !allowedRoles.contains(currentUser.role)) {
      return const Scaffold(
        body: Center(child: Text('Accès réservé à la modération.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Modération des commentaires')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : commentaires.isEmpty
              ? const Center(child: Text('Aucun commentaire signalé.'))
              : ListView.builder(
                  itemCount: commentaires.length,
                  itemBuilder: (context, i) {
                    final c = commentaires[i];
                    final ressource = c['ressource'];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:
                                  const Text('Détails du commentaire signalé'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ressource : ${ressource['nom']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Description : ${ressource['description']}'),
                                    const SizedBox(height: 16),
                                    const Text('Contenu de la ressource :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    if (ressource['format'] == 1)
                                      Text(ressource['contenue'])
                                    else if (ressource['format'] == 2)
                                      Image.network(
                                        ressource['contenue'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                    else if (ressource['format'] == 3)
                                      Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: ressource['contenue']
                                                    .startsWith('http')
                                                ? Image.network(
                                                    ressource['contenue'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(
                                                            Icons.broken_image),
                                                  )
                                                : const Icon(Icons.videocam),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Vidéo : ${ressource['contenue']}'),
                                        ],
                                      ),
                                    const Divider(height: 32),
                                    const Text('Commentaire signalé :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(c['contenue'] ?? ''),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Par : ${auteurs[c['utilisateurID'].toString()] ?? 'Utilisateur inconnu'}',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Text(
                                      'Le ${formatDate(c['date'].toString())}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.flag,
                                            color: Colors.orange, size: 20),
                                        const SizedBox(width: 4),
                                        Text(nbSignalements[c['id']]
                                                ?.toString() ??
                                            '0'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    auteurs[c['utilisateurID'].toString()] ??
                                        'Utilisateur inconnu',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    c['date'] != null
                                        ? formatDate(c['date'].toString())
                                        : '',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ressource : ${ressource['nom']}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(c['contenue'] ?? '',
                                  style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.flag,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 4),
                                  Text(nbSignalements[c['id']]?.toString() ??
                                      '0'),
                                  const Spacer(),
                                  if (c['visible'] == true)
                                    TextButton.icon(
                                      icon: const Icon(Icons.visibility_off,
                                          color: Colors.orange),
                                      label: const Text('Masquer'),
                                      onPressed: () =>
                                          _setVisible(c['id'], false),
                                    )
                                  else
                                    TextButton.icon(
                                      icon: const Icon(Icons.visibility,
                                          color: Colors.green),
                                      label: const Text('Restaurer'),
                                      onPressed: () =>
                                          _setVisible(c['id'], true),
                                    ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    label: const Text('Supprimer'),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Supprimer le commentaire'),
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
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _deleteComment(c['id']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
