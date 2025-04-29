import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationRessourcesPage extends StatefulWidget {
  const ModerationRessourcesPage({Key? key}) : super(key: key);

  @override
  State<ModerationRessourcesPage> createState() =>
      _ModerationRessourcesPageState();
}

class _ModerationRessourcesPageState extends State<ModerationRessourcesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> signalements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerSignalements();
  }

  Future<void> chargerSignalements() async {
    try {
      final response = await supabase.from('signalementRessource').select('''
            *,
            ressource:ressourceID(nom, description),
            utilisateur:utilisateurID(email)
          ''').eq('verifier', false).order('date', ascending: false);

      setState(() {
        signalements = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      print('Erreur lors du chargement des signalements: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> traiterSignalement(
      int signalementId, String reponse, bool supprimer) async {
    try {
      // Mettre à jour le signalement
      await supabase.from('signalementRessource').update({
        'reponseAdmin': reponse,
        'verifier': true,
      }).eq('id', signalementId);

      if (supprimer) {
        // Récupérer l'ID de la ressource
        final ressourceId = signalements
            .firstWhere((s) => s['id'] == signalementId)['ressource_id'];

        // Supprimer la ressource
        await supabase.from('ressource').delete().eq('id', ressourceId);
      }

      // Recharger les signalements
      await chargerSignalements();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(supprimer
                ? 'Ressource supprimée et signalement traité'
                : 'Signalement traité'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      print('Erreur lors du traitement du signalement: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du traitement du signalement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AppAuthState>(context).currentUser;
    final allowedRoles = ['1', '2', '3'];

    if (currentUser == null || !allowedRoles.contains(currentUser.role)) {
      return const Scaffold(
        body: Center(child: Text('Accès réservé à la modération.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modération des ressources'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : signalements.isEmpty
              ? const Center(child: Text('Aucun signalement en attente'))
              : ListView.builder(
                  itemCount: signalements.length,
                  itemBuilder: (context, index) {
                    final signalement = signalements[index];
                    final ressource = signalement['ressource'];
                    final utilisateur = signalement['utilisateur'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(ressource['nom']),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Description : ${ressource['description']}'),
                                    const SizedBox(height: 16),
                                    const Text('Contenu de la ressource :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<Map<String, dynamic>?>(
                                      future: supabase
                                          .from('ressource')
                                          .select('*')
                                          .eq('id', signalement['ressourceID'])
                                          .single(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (!snapshot.hasData) {
                                          return const Text(
                                              'Ressource non trouvée');
                                        }
                                        final ressourceComplete =
                                            snapshot.data!;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (ressourceComplete['format'] ==
                                                1)
                                              Text(
                                                  ressourceComplete['contenue'])
                                            else if (ressourceComplete[
                                                    'format'] ==
                                                2)
                                              Image.network(
                                                ressourceComplete['contenue'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.broken_image),
                                              )
                                            else if (ressourceComplete[
                                                    'format'] ==
                                                3)
                                              Column(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: ressourceComplete[
                                                                'contenue']
                                                            .startsWith('http')
                                                        ? Image.network(
                                                            ressourceComplete[
                                                                'contenue'],
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                const Icon(Icons
                                                                    .broken_image),
                                                          )
                                                        : const Icon(
                                                            Icons.videocam),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                      'Vidéo : ${ressourceComplete['contenue']}'),
                                                ],
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    const Divider(),
                                    Text(
                                        'Signalé par : ${utilisateur['email']}'),
                                    Text(
                                        'Motif : ${signalement['commentaire']}'),
                                    Text('Date : ${signalement['date']}'),
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
                          padding: const EdgeInsets.all(16.0),
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
                              Text('Description : ${ressource['description']}'),
                              const SizedBox(height: 8),
                              Text('Signalé par : ${utilisateur['email']}'),
                              const SizedBox(height: 8),
                              Text('Motif : ${signalement['commentaire']}'),
                              const SizedBox(height: 8),
                              Text('Date : ${signalement['date']}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => traiterSignalement(
                                      signalement['id'],
                                      'Signalement rejeté',
                                      false,
                                    ),
                                    child: const Text('Rejeter'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => traiterSignalement(
                                      signalement['id'],
                                      'Ressource supprimée',
                                      true,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Supprimer la ressource'),
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
