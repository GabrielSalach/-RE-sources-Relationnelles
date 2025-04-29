import 'package:flutter/material.dart';
import '../models/ressource.dart';
import '../services/ressource_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import '../pages/profil_public_page.dart';
import 'commentaires_section.dart';

class RessourceCard extends StatefulWidget {
  final Ressource ressource;
  const RessourceCard({super.key, required this.ressource});

  @override
  State<RessourceCard> createState() => _RessourceCardState();
}

class _RessourceCardState extends State<RessourceCard> {
  String? auteur;
  final RessourceService _ressourceService = RessourceService();
  bool isLiked = false;
  bool isFavori = false;
  bool isSignaled = false;
  int nbLike = 0;
  int nbReport = 0;
  String? utilisateurId;
  bool isFavoriLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AppAuthState>().currentUser;
      print('RessourceCard - User ID: ${currentUser?.id}');
      utilisateurId = currentUser?.id;
      _initStates();
    });
    _loadAuteur();
    nbLike = widget.ressource.nbLike;
    nbReport = widget.ressource.nbReport;
  }

  Future<void> _initStates() async {
    print('_initStates - Début de l\'initialisation');
    if (utilisateurId == null) {
      print('_initStates - Pas d\'utilisateur connecté');
      return;
    }

    try {
      final intId = int.parse(utilisateurId!);
      print('_initStates - Vérification des états pour l\'utilisateur $intId');

      final liked =
          await _ressourceService.hasLiked(widget.ressource.id, intId);
      print('_initStates - hasLiked: $liked');

      final favori =
          await _ressourceService.hasFavori(widget.ressource.id, intId);
      print('_initStates - hasFavori: $favori');

      final signaled =
          await _ressourceService.hasSignaled(widget.ressource.id, intId);
      print('_initStates - hasSignaled: $signaled');

      if (mounted) {
        setState(() {
          isLiked = liked;
          isFavori = favori;
          isSignaled = signaled;
          print(
              '_initStates - États mis à jour - liked: $isLiked, favori: $isFavori, signaled: $isSignaled');
        });
      }

      await _refreshNbLike();
    } catch (e) {
      print('_initStates - Erreur: $e');
    }
  }

  Future<void> _refreshNbLike() async {
    try {
      final nb = await _ressourceService.fetchNbLike(widget.ressource.id);
      if (mounted) {
        setState(() {
          nbLike = nb;
          print('_refreshNbLike - Nouveau nombre de likes: $nbLike');
        });
      }
    } catch (e) {
      print('_refreshNbLike - Erreur: $e');
    }
  }

  Future<void> _loadAuteur() async {
    final nomPrenom =
        await _ressourceService.getAuteurNomPrenom(widget.ressource.id);
    if (mounted) {
      setState(() {
        auteur = nomPrenom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contenuWidget;
    String description = widget.ressource.description;
    String contenu = widget.ressource.contenue;
    bool descriptionTronquee = false;
    bool contenuTronque = false;
    const int maxChars = 200;
    if (description.length > maxChars) {
      description = '${description.substring(0, maxChars)}...';
      descriptionTronquee = true;
    }
    if (widget.ressource.format == 1 && contenu.length > maxChars) {
      contenu = '${contenu.substring(0, maxChars)}...';
      contenuTronque = true;
    }
    switch (widget.ressource.format) {
      case 1:
        contenuWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contenu,
              style: const TextStyle(fontSize: 16),
            ),
            if (contenuTronque)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(widget.ressource.nom),
                      content: Text(widget.ressource.contenue),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Lire la suite',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        );
        break;
      case 2:
        contenuWidget = Image.network(
          widget.ressource.contenue,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        );
        break;
      case 3:
        contenuWidget = Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.ressource.contenue.startsWith('http')
                  ? Image.network(
                      widget.ressource.contenue,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.videocam),
            ),
            const SizedBox(height: 8),
            Text('Vidéo : ${widget.ressource.contenue}',
                style: const TextStyle(fontSize: 14)),
          ],
        );
        break;
      default:
        contenuWidget = const Text('Format inconnu');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(widget.ressource.nom),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (auteur != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text('Auteur : $auteur',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          Text(widget.ressource.description,
                              style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 12),
                          if (widget.ressource.format == 1)
                            Text(widget.ressource.contenue,
                                style: const TextStyle(fontSize: 16))
                          else if (widget.ressource.format == 2)
                            Image.network(widget.ressource.contenue,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image))
                          else if (widget.ressource.format == 3)
                            Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: widget.ressource.contenue
                                          .startsWith('http')
                                      ? Image.network(widget.ressource.contenue,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.broken_image))
                                      : const Icon(Icons.videocam),
                                ),
                                const SizedBox(height: 8),
                                Text('Vidéo : ${widget.ressource.contenue}',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Text(
                              'Le ${widget.ressource.date.day.toString().padLeft(2, '0')}/${widget.ressource.date.month.toString().padLeft(2, '0')}/${widget.ressource.date.year}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text('Commentaires',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          CommentairesSection(ressourceId: widget.ressource.id),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.ressource.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      if (auteur != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () async {
                              final auteurId = await _ressourceService
                                  .getAuteurUtilisateurId(widget.ressource.id);
                              if (auteurId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilPublicPage(
                                        utilisateurId: auteurId),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  auteur!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.open_in_new,
                                    size: 16, color: Colors.blue),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(color: Colors.black54)),
                  if (descriptionTronquee)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(widget.ressource.nom),
                            content: Text(widget.ressource.description),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Lire la suite',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline)),
                    ),
                  const SizedBox(height: 8),
                  contenuWidget,
                  const SizedBox(height: 8),
                  Text(
                      'Le ${widget.ressource.date.day.toString().padLeft(2, '0')}/${widget.ressource.date.month.toString().padLeft(2, '0')}/${widget.ressource.date.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Colors.blue : Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: 'J\'aime',
                  onPressed: utilisateurId == null
                      ? null
                      : () async {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          if (isLiked) {
                            await _ressourceService.likeRessource(
                                widget.ressource.id, int.parse(utilisateurId!));
                          } else {
                            await _ressourceService.unlikeRessource(
                                widget.ressource.id, int.parse(utilisateurId!));
                          }
                          await _refreshNbLike();
                        },
                ),
                Text('$nbLike'),
                const SizedBox(width: 8),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFavori ? Icons.star : Icons.star_border,
                      key: ValueKey(isFavori),
                      color: isFavori ? Colors.amber : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  tooltip:
                      isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
                  onPressed:
                      utilisateurId == null || isSignaled || isFavoriLoading
                          ? null
                          : () async {
                              setState(() {
                                isFavoriLoading = true;
                              });
                              try {
                                setState(() {
                                  isFavori = !isFavori;
                                });
                                if (isFavori) {
                                  await _ressourceService.addFavoris(
                                      widget.ressource.id,
                                      int.parse(utilisateurId!));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Ajouté aux favoris'),
                                          backgroundColor: Colors.green),
                                    );
                                  }
                                } else {
                                  await _ressourceService.removeFavoris(
                                      widget.ressource.id,
                                      int.parse(utilisateurId!));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Retiré des favoris'),
                                          backgroundColor: Colors.orange),
                                    );
                                  }
                                }
                              } finally {
                                setState(() {
                                  isFavoriLoading = false;
                                });
                              }
                            },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.flag,
                    color: isSignaled ? Colors.red : Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: isSignaled ? 'Déjà signalé' : 'Signaler',
                  onPressed: utilisateurId == null || isSignaled
                      ? null
                      : () {
                          final TextEditingController motifController =
                              TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Signaler cette ressource'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                      'Pour quelle raison souhaitez-vous signaler cette ressource ?'),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: motifController,
                                    decoration: const InputDecoration(
                                      labelText: 'Motif du signalement',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (motifController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Veuillez indiquer un motif'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    await _ressourceService.signalerRessource(
                                      widget.ressource.id,
                                      int.parse(utilisateurId!),
                                      motifController.text.trim(),
                                    );
                                    setState(() {
                                      isSignaled = true;
                                      nbReport++;
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Ressource signalée'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Signaler',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                ),
                Text('$nbReport'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
