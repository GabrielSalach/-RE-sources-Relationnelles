import 'package:flutter/material.dart';
import '../services/ressource_service.dart';
import '../widgets/ressource_card.dart';
import '../models/ressource.dart';

class ResourcesListPage extends StatefulWidget {
  const ResourcesListPage({super.key});

  @override
  State<ResourcesListPage> createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {
  late Future<List<Ressource>> _ressourcesFuture;
  final RessourceService _ressourceService = RessourceService();
  List<Ressource> _allRessources = [];
  String _searchQuery = '';
  int? _selectedFormat; // null = tous, 1=texte, 2=photo, 3=vidéo

  @override
  void initState() {
    super.initState();
    _ressourcesFuture = _ressourceService.getAllRessources();
    _ressourcesFuture.then((data) {
      setState(() {
        _allRessources = data;
      });
    });
  }

  List<Ressource> get _filteredRessources {
    return _allRessources.where((r) {
      final matchesSearch =
          r.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFormat =
          _selectedFormat == null || r.format == _selectedFormat;
      return matchesSearch && matchesFormat;
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
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          // Initialiser _allRessources si vide ou différent
          if (_allRessources.isEmpty ||
              _allRessources.length != snapshot.data!.length) {
            _allRessources = snapshot.data!;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
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
