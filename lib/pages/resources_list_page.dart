import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/api_service.dart';

class ResourcesListPage extends StatefulWidget {
  const ResourcesListPage({super.key});

  @override
  State<ResourcesListPage> createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {
  final ApiService _apiService = ApiService();
  List<Resource> _resources = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Famille',
    'Amis',
    'Couple',
    'Travail'
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final resources = await _apiService.getResources();
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Resource> get _filteredResources {
    return _resources.where((resource) {
      final matchesSearch =
          resource.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              resource.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Tous' || resource.format == _selectedCategory;
      return matchesSearch && matchesCategory;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barre de recherche
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
                const SizedBox(height: 16),
                // Filtres par catégorie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : 'Tous';
                            });
                          },
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Erreur: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadResources,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _filteredResources.isEmpty
                        ? const Center(
                            child: Text('Aucune ressource trouvée'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadResources,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredResources.length,
                              itemBuilder: (context, index) {
                                final resource = _filteredResources[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      child: const Icon(Icons.article),
                                    ),
                                    title: Text(
                                      resource.nom,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(resource.description),
                                        const SizedBox(height: 4),
                                        Chip(
                                          label: Text(
                                            resource.format,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.favorite_border),
                                          onPressed: () {
                                            // TODO: Ajouter aux favoris
                                          },
                                        ),
                                        const Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                    onTap: () {
                                      // TODO: Navigation vers le détail de la ressource
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
