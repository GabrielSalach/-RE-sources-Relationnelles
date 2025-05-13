import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'models/resource.dart';
import 'models/ressource.dart';
import 'services/api_service.dart';
import 'services/auth_state.dart';
import 'pages/inscription_page.dart';
import 'pages/login_page.dart';
import 'pages/resources_list_page.dart';
import 'pages/favoris_page.dart';
import 'pages/profil_page.dart';
import 'pages/profil_public_page.dart';
import 'widgets/ressource_card.dart';
import 'pages/moderation_commentaires_page.dart';
import 'pages/moderation_page.dart';
import 'pages/progression_page.dart';
import 'pages/create_resource_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppAuthState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '(RE) Sources Relationnels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000091), // Bleu France
          primary: const Color(0xFF000091),
          secondary: const Color(0xFFE1000F), // Rouge France
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000091),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/resources': (context) => const ResourcesListPage(),
        '/favoris': (context) => const FavorisPage(),
        '/profil': (context) => const ProfilPage(),
        '/resources/create': (context) => const CreateResourcePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Resource> _resources = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadResources();
    // Attendre que le widget soit monté avant de charger l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // L'utilisateur est déjà chargé dans le constructeur de AppAuthState
      // donc pas besoin d'appeler loadCurrentUser ici
    });
  }

  Future<void> _loadResources() async {
    try {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthState>(
      builder: (context, authState, child) {
        print(
            'HomePage: Rebuild avec isAuthenticated = ${authState.isAuthenticated}');
        final isAuthenticated = authState.isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              '(RE) Sources Relationnels',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              if (isAuthenticated) ...[
                // Bouton modération (si Super Admin, Admin, Modérateur)
                if (authState.currentUser != null &&
                    (authState.currentUser!.role == '1' ||
                        authState.currentUser!.role == '2' ||
                        authState.currentUser!.role == '3'))
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Modération',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModerationPage(),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    print('HomePage: Déconnexion demandée');
                    await authState.signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Déconnexion réussie'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ] else
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    print('HomePage: Navigation vers la page de connexion');
                    Navigator.pushNamed(context, '/login');
                  },
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Erreur: $_error'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          if (!isAuthenticated)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Bienvenue sur (RE) Sources Relationnels',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Une plateforme pour enrichir vos relations et améliorer votre qualité de vie',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/login');
                                        },
                                        icon: const Icon(Icons.login),
                                        label: const Text('Se connecter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/inscription');
                                        },
                                        icon: const Icon(Icons.person_add),
                                        label: const Text('S\'inscrire'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          // Section Catégories
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Découvrez par catégorie',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  children: [
                                    _buildCategoryCard(
                                      context,
                                      'Famille',
                                      Icons.family_restroom,
                                      const Color(0xFF0063CB),
                                    ),
                                    _buildCategoryCard(
                                      context,
                                      'Amis',
                                      Icons.people,
                                      const Color(0xFFE1000F),
                                    ),
                                    _buildCategoryCard(
                                      context,
                                      'Couple',
                                      Icons.favorite,
                                      const Color(0xFF009099),
                                    ),
                                    _buildCategoryCard(
                                      context,
                                      'Travail',
                                      Icons.work,
                                      const Color(0xFF6A6AF4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Section Ressources récentes
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ressources récentes',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/resources');
                                      },
                                      icon: const Icon(Icons.search),
                                      label: const Text('Voir tout'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _resources.length,
                                  itemBuilder: (context, index) {
                                    final resource = _resources[index];
                                    final ressource =
                                        Ressource.fromJson(resource.toJson());
                                    return RessourceCard(ressource: ressource);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          floatingActionButton: isAuthenticated
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/resources/create');
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Rechercher',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favoris'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books), label: 'Bibliothèque'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.primary,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              switch (index) {
                case 0: // Accueil
                  break;
                case 1: // Rechercher
                  Navigator.pushNamed(context, '/resources');
                  break;
                case 2: // Favoris
                  if (isAuthenticated) {
                    Navigator.pushNamed(context, '/favoris');
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                  break;
                case 3: // Progression
                  if (isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgressionPage(),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                  break;
                case 4: // Profil
                  if (isAuthenticated) {
                    final userId = authState.currentUser?.id;
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilPublicPage(
                              utilisateurId: int.parse(userId)),
                        ),
                      );
                    }
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourcesListPage(initialCategorie: title),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
