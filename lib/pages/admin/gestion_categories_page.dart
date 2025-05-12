import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_state.dart';

class GestionCategoriesPage extends StatefulWidget {
  const GestionCategoriesPage({Key? key}) : super(key: key);

  @override
  State<GestionCategoriesPage> createState() => _GestionCategoriesPageState();
}

class _GestionCategoriesPageState extends State<GestionCategoriesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => isLoading = true);
      final response = await supabase.from('categorie').select().order('nom');
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCategorie(int id) async {
    try {
      // Vérifier si la catégorie est utilisée
      final ressources = await supabase
          .from('categorieRessource')
          .select()
          .eq('categorieID', id);

      if (ressources.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cette catégorie est utilisée par des ressources et ne peut pas être supprimée.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await supabase.from('categorie').delete().eq('id', id);
      await _loadCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCategoryDialog([Map<String, dynamic>? categorie]) async {
    final isEditing = categorie != null;
    final nomController = TextEditingController(text: categorie?['nom'] ?? '');
    final ageMinController =
        TextEditingController(text: categorie?['ageMin']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Ex: Famille, Amis, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageMinController,
                decoration: const InputDecoration(
                  labelText: 'Âge minimum recommandé',
                  hintText: 'Laissez vide si non applicable',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nom = nomController.text.trim();
              if (nom.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom de la catégorie est requis'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              int? ageMin;
              if (ageMinController.text.isNotEmpty) {
                ageMin = int.tryParse(ageMinController.text);
                if (ageMin == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('L\'âge minimum doit être un nombre valide'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }

              try {
                if (isEditing) {
                  await supabase.from('categorie').update({
                    'nom': nom,
                    'ageMin': ageMin,
                  }).eq('id', categorie['id']);
                } else {
                  await supabase.from('categorie').insert({
                    'nom': nom,
                    'ageMin': ageMin,
                  });
                }
                if (mounted) {
                  Navigator.pop(context);
                  await _loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          isEditing ? 'Catégorie modifiée' : 'Catégorie créée'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Modifier' : 'Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AppAuthState>(context).currentUser;
    final allowedRoles = ['1', '2'];

    if (currentUser == null || !allowedRoles.contains(currentUser.role)) {
      return const Scaffold(
        body: Center(child: Text('Accès réservé aux administrateurs.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Erreur : $error'))
              : categories.isEmpty
                  ? const Center(child: Text('Aucune catégorie'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final categorie = categories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(categorie['nom']),
                            subtitle: categorie['ageMin'] != null
                                ? Text(
                                    'Âge minimum : ${categorie['ageMin']} ans')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showCategoryDialog(categorie),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Confirmer la suppression'),
                                        content: const Text(
                                            'Voulez-vous vraiment supprimer cette catégorie ?'),
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
                                      await _deleteCategorie(categorie['id']);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
