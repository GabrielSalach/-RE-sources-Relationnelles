import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import '../services/ressource_service.dart';
import '../models/ressource.dart';
import '../widgets/ressource_card.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  final RessourceService _ressourceService = RessourceService();
  List<Ressource> _ressources = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavoris());
  }

  Future<void> _loadFavoris() async {
    final currentUser = context.read<AppAuthState>().currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _error = "Vous devez être connecté pour voir vos favoris.";
      });
      return;
    }
    try {
      // Récupérer les IDs des ressources favorites
      final favorisRows = await _ressourceService
          .getFavorisRessourceIds(int.parse(currentUser.id));
      if (favorisRows.isEmpty) {
        setState(() {
          _ressources = [];
          _isLoading = false;
        });
        return;
      }
      // Charger les ressources correspondantes
      final ressources =
          await _ressourceService.getRessourcesByIds(favorisRows);
      setState(() {
        _ressources = ressources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _ressources.isEmpty
                  ? const Center(child: Text('Aucune ressource en favori.'))
                  : ListView.builder(
                      itemCount: _ressources.length,
                      itemBuilder: (context, index) {
                        return RessourceCard(ressource: _ressources[index]);
                      },
                    ),
    );
  }
}
