import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ressource.dart';
import '../services/ressource_service.dart';
import '../services/auth_state.dart';
import '../widgets/ressource_card.dart';

enum SortOption {
  dateDesc,
  dateAsc,
  nomAZ,
  nomZA,
}

class ProgressionPage extends StatefulWidget {
  final String? initialCategorie;

  const ProgressionPage({
    super.key,
    this.initialCategorie,
  });

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RessourceService _ressourceService = RessourceService();
  final TextEditingController _searchController = TextEditingController();
  SortOption _currentSort = SortOption.dateDesc;
  String _searchQuery = '';
  int? _selectedFormat;
  String? _selectedCategorie;
  bool _isFilterVisible = false;

  final List<String> _categories = [
    'Famille',
    'Amis',
    'Couple',
    'Travail',
  ];

  final List<Map<String, dynamic>> _formats = [
    {'id': 1, 'name': 'Texte'},
    {'id': 2, 'name': 'Image'},
    {'id': 3, 'name': 'Vidéo'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Initialiser la catégorie si elle est fournie
    if (widget.initialCategorie != null) {
      _selectedCategorie = widget.initialCategorie;
      _isFilterVisible = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Ressource> _filterAndSortRessources(List<Ressource> ressources) {
    // Filtrage par recherche
    var filteredRessources = ressources.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filtrage par format
    if (_selectedFormat != null) {
      filteredRessources =
          filteredRessources.where((r) => r.format == _selectedFormat).toList();
    }

    // Filtrage par catégorie
    if (_selectedCategorie != null) {
      filteredRessources = filteredRessources
          .where((r) => r.categorie == _selectedCategorie)
          .toList();
    }

    // Tri
    switch (_currentSort) {
      case SortOption.dateDesc:
        filteredRessources.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        filteredRessources.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.nomAZ:
        filteredRessources.sort((a, b) => a.nom.compareTo(b.nom));
        break;
      case SortOption.nomZA:
        filteredRessources.sort((a, b) => b.nom.compareTo(a.nom));
        break;
    }

    return filteredRessources;
  }

  Widget _buildFilterBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isFilterVisible ? null : 0,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trier par :',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Plus récent'),
                      selected: _currentSort == SortOption.dateDesc,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentSort = SortOption.dateDesc);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Plus ancien'),
                      selected: _currentSort == SortOption.dateAsc,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentSort = SortOption.dateAsc);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('A à Z'),
                      selected: _currentSort == SortOption.nomAZ,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentSort = SortOption.nomAZ);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Z à A'),
                      selected: _currentSort == SortOption.nomZA,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentSort = SortOption.nomZA);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Format :',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Tous'),
                      selected: _selectedFormat == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFormat = null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._formats.map((format) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(format['name']),
                            selected: _selectedFormat == format['id'],
                            onSelected: (selected) {
                              setState(() => _selectedFormat =
                                  selected ? format['id'] : null);
                            },
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Catégorie :',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Toutes'),
                      selected: _selectedCategorie == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategorie = null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._categories.map((categorie) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(categorie),
                            selected: _selectedCategorie == categorie,
                            onSelected: (selected) {
                              setState(() => _selectedCategorie =
                                  selected ? categorie : null);
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthState>(
      builder: (context, authState, child) {
        final userId = authState.currentUser?.id;

        if (userId == null) {
          return const Scaffold(
            body: Center(
              child:
                  Text('Veuillez vous connecter pour voir votre bibliothèque'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ma bibliothèque'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une ressource...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.filter_list,
                                color: _isFilterVisible ? Colors.blue : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFilterVisible = !_isFilterVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Déjà consultées'),
                      Tab(text: 'À voir plus tard'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRessourceList(userId, true),
                    _buildRessourceList(userId, false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRessourceList(String userId, bool isExploitees) {
    return FutureBuilder<List<Ressource>>(
      future: _loadRessources(userId, isExploitees),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
                'Erreur lors du chargement des ressources: ${snapshot.error}'),
          );
        }

        final ressources = _filterAndSortRessources(snapshot.data ?? []);

        if (ressources.isEmpty) {
          if (_searchQuery.isNotEmpty ||
              _selectedFormat != null ||
              _selectedCategorie != null) {
            return const Center(
              child: Text('Aucune ressource ne correspond aux critères'),
            );
          }
          return Center(
            child: Text(
              isExploitees
                  ? 'Aucune ressource consultée pour le moment'
                  : 'Aucune ressource mise de côté pour le moment',
            ),
          );
        }

        return ListView.builder(
          itemCount: ressources.length,
          itemBuilder: (context, index) {
            return RessourceCard(ressource: ressources[index]);
          },
        );
      },
    );
  }

  Future<List<Ressource>> _loadRessources(
      String userId, bool isExploitees) async {
    try {
      final userIdInt = int.parse(userId);
      final table = isExploitees ? 'ressourceExploitee' : 'ressourceMiseDeCote';

      final result = await _ressourceService.supabase
          .from(table)
          .select('ressourceid')
          .eq('utilisateurid', userIdInt);

      final ressourceIds =
          result.map<int>((row) => row['ressourceid'] as int).toList();

      return await _ressourceService.getRessourcesByIdList(ressourceIds);
    } catch (e) {
      throw Exception('Erreur lors du chargement des ressources: $e');
    }
  }
}
