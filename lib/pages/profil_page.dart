import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _dateNaissance;
  bool _isLoading = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppAuthState>().currentUser;
    if (user != null) {
      _nomController.text = user.nom;
      _prenomController.text = user.prenom;
      _emailController.text = user.email;
      _bioController.text = user.bio ?? '';
      _dateNaissance = user.dateNaissance;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _feedback = null;
    });
    final user = context.read<AppAuthState>().currentUser;
    if (user == null) return;
    try {
      // Mise à jour des infos de base
      await Supabase.instance.client.from('utilisateur').update({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
      }).eq('id', user.id);
      // Mise à jour du mot de passe si renseigné
      if (_passwordController.text.isNotEmpty) {
        await Supabase.instance.client
            .from('utilisateur')
            .update({'motDePasse': _passwordController.text}).eq('id', user.id);
      }
      setState(() {
        _feedback = 'Profil mis à jour avec succès !';
      });
      await context.read<AppAuthState>().loadCurrentUser();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() {
        _feedback = 'Erreur lors de la mise à jour : $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthState>().currentUser;
    final isLoading = context.watch<AppAuthState>().isLoading || _isLoading;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun utilisateur connecté.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue.shade900,
                            child: const Icon(Icons.person,
                                size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${user.prenom} ${user.nom}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ obligatoire'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ obligatoire'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ obligatoire'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 32),
                    const Text('Changer le mot de passe',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Nouveau mot de passe'),
                      obscureText: true,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe'),
                      obscureText: true,
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty &&
                            value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_feedback != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _feedback!,
                          style: TextStyle(
                            color: _feedback!.contains('succès')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
