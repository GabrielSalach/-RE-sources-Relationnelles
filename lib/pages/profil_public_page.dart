import 'package:flutter/material.dart';
import '../services/ressource_service.dart';
import '../models/ressource.dart';
import '../widgets/ressource_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import 'profil_page.dart';

class ProfilPublicPage extends StatefulWidget {
  final int utilisateurId;
  const ProfilPublicPage({super.key, required this.utilisateurId});

  @override
  State<ProfilPublicPage> createState() => _ProfilPublicPageState();
}

class _ProfilPublicPageState extends State<ProfilPublicPage> {
  final RessourceService _ressourceService = RessourceService();
  Map<String, dynamic>? utilisateur;
  List<Ressource> ressources = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Charger les infos utilisateur
      final userData = await Supabase.instance.client
          .from('utilisateur')
          .select('id, nom, prenom, bio')
          .eq('id', widget.utilisateurId)
          .maybeSingle();
      // Charger les ressources publiées
      final res =
          await _ressourceService.getRessourcesByUser(widget.utilisateurId);
      setState(() {
        utilisateur = userData;
        ressources = res;
        isLoading = false;
      });
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
    final isOwnProfile = currentUser != null &&
        int.tryParse(currentUser.id) == widget.utilisateurId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil public'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : utilisateur == null
                  ? const Center(child: Text('Utilisateur introuvable.'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            color: Colors.blue.shade900,
                            padding: const EdgeInsets.only(top: 32, bottom: 16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 60, color: Colors.blue.shade900),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${utilisateur!['prenom']} ${utilisateur!['nom']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (utilisateur!['bio'] != null &&
                                    utilisateur!['bio'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      utilisateur!['bio'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if (isOwnProfile)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfilPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Modifier mon profil'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ressources publiées',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ressources.isEmpty
                                    ? const Text('Aucune ressource publiée.')
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: ressources.length,
                                        itemBuilder: (context, index) {
                                          return RessourceCard(
                                              ressource: ressources[index]);
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
