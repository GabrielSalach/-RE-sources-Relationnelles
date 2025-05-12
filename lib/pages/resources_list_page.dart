import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ressource_service.dart';
import '../widgets/ressource_card.dart';
import '../models/ressource.dart';

class ResourcesListPage extends StatefulWidget {
  final String? initialCategorie;

  const ResourcesListPage({
    super.key,
    this.initialCategorie,
  });

  @override
  State<ResourcesListPage> createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {
  late Future<List<Ressource>> _ressourcesFuture;
  final RessourceService _ressourceService = RessourceService();
  List<Ressource> _allRessources = [];
  List<Map<String, dynamic>> _categories = [];
  Map<int, List<int>> _ressourcesCategories = {};
  String _searchQuery = '';
  int? _selectedFormat;
  int? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _ressourcesFuture = _ressourceService.getAllRessources();
    await _loadCategories();

    // Si une catégorie initiale est fournie, on trouve son ID
    if (widget.initialCategorie != null) {
      final categorie = _categories.firstWhere(
        (cat) => cat['nom'] == widget.initialCategorie,
        orElse: () => {'id': null},
      );
      _selectedCategory = categorie['id'];
    }

    final ressources = await _ressourcesFuture;
    setState(() {
      _allRessources = ressources;
    });
    await _loadRessourcesCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categorie')
          .select()
          .order('nom');
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadRessourcesCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categorieRessource')
          .select('ressourceID, categorieID');

      Map<int, List<int>> mapping = {};
      for (var item in response) {
        final ressourceId = item['ressourceID'] as int;
        final categorieId = item['categorieID'] as int;
        if (!mapping.containsKey(ressourceId)) {
          mapping[ressourceId] = [];
        }
        mapping[ressourceId]!.add(categorieId);
      }

      setState(() {
        _ressourcesCategories = mapping;
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories des ressources: $e');
    }
  }

  List<Ressource> get _filteredRessources {
    return _allRessources.where((r) {
      final matchesSearch =
          r.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFormat =
          _selectedFormat == null || r.format == _selectedFormat;
      final matchesCategory = _selectedCategory == null ||
          (_ressourcesCategories[r.id]?.contains(_selectedCategory) ?? false);
      return matchesSearch && matchesFormat && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les ressources'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Ressource>>(
        future: _ressourcesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingCategories) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur lors du chargement :\n${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune ressource disponible.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une ressource...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filtres de format
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Tous les formats'),
                            selected: _selectedFormat == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedFormat = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Texte'),
                            selected: _selectedFormat == 1,
                            onSelected: (_) {
                              setState(() {
                                _selectedFormat = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Photo'),
                            selected: _selectedFormat == 2,
                            onSelected: (_) {
                              setState(() {
                                _selectedFormat = 2;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Vidéo'),
                            selected: _selectedFormat == 3,
                            onSelected: (_) {
                              setState(() {
                                _selectedFormat = 3;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filtres de catégorie
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Toutes les catégories'),
                            selected: _selectedCategory == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ..._categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(cat['nom']),
                                  selected: _selectedCategory == cat['id'],
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategory = cat['id'];
                                    });
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredRessources.isEmpty
                    ? const Center(child: Text('Aucune ressource trouvée.'))
                    : ListView.builder(
                        itemCount: _filteredRessources.length,
                        itemBuilder: (context, index) {
                          final ressource = _filteredRessources[index];
                          return RessourceCard(ressource: ressource);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
