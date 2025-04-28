import 'package:flutter/material.dart';
import '../models/ressource.dart';
import '../services/ressource_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';

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
      utilisateurId = currentUser?.id;
      _initStates();
    });
    _loadAuteur();
    nbLike = widget.ressource.nbLike;
    nbReport = widget.ressource.nbReport;
  }

  Future<void> _initStates() async {
    if (utilisateurId == null) return;
    final intId = int.parse(utilisateurId!);
    final liked = await _ressourceService.hasLiked(widget.ressource.id, intId);
    final favori =
        await _ressourceService.hasFavori(widget.ressource.id, intId);
    final signaled =
        await _ressourceService.hasSignaled(widget.ressource.id, intId);
    setState(() {
      isLiked = liked;
      isFavori = favori;
      isSignaled = signaled;
    });
    await _refreshNbLike();
  }

  Future<void> _refreshNbLike() async {
    final nb = await _ressourceService.fetchNbLike(widget.ressource.id);
    setState(() {
      nbLike = nb;
    });
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

    return GestureDetector(
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  Text(
                    widget.ressource.description,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  if (widget.ressource.format == 1)
                    Text(
                      widget.ressource.contenue,
                      style: const TextStyle(fontSize: 16),
                    )
                  else if (widget.ressource.format == 2)
                    Image.network(
                      widget.ressource.contenue,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  else if (widget.ressource.format == 3)
                    Column(
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
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Le ${widget.ressource.date.day.toString().padLeft(2, '0')}/${widget.ressource.date.month.toString().padLeft(2, '0')}/${widget.ressource.date.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
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
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      child: Text(
                        auteur!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.black54),
              ),
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
                  child: const Text(
                    'Lire la suite',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              contenuWidget,
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Le ${widget.ressource.date.day.toString().padLeft(2, '0')}/${widget.ressource.date.month.toString().padLeft(2, '0')}/${widget.ressource.date.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Colors.blue : Colors.grey.shade600,
                          size: 20,
                        ),
                        tooltip: 'J\'aime',
                        onPressed: utilisateurId == null || isSignaled
                            ? null
                            : () async {
                                setState(() {
                                  isLiked = !isLiked;
                                });
                                if (isLiked) {
                                  await _ressourceService.likeRessource(
                                      widget.ressource.id,
                                      int.parse(utilisateurId!));
                                } else {
                                  await _ressourceService.unlikeRessource(
                                      widget.ressource.id,
                                      int.parse(utilisateurId!));
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
                            color:
                                isFavori ? Colors.amber : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        tooltip: isFavori
                            ? 'Retirer des favoris'
                            : 'Ajouter aux favoris',
                        onPressed: utilisateurId == null ||
                                isSignaled ||
                                isFavoriLoading
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                        tooltip: 'Signaler',
                        onPressed: utilisateurId == null || isSignaled
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'Signaler cette ressource ?'),
                                    content: const Text(
                                        'Voulez-vous vraiment signaler cette ressource ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _ressourceService
                                              .signalerRessource(
                                                  widget.ressource.id,
                                                  int.parse(utilisateurId!));
                                          setState(() {
                                            isSignaled = true;
                                            nbReport++;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Signaler',
                                            style:
                                                TextStyle(color: Colors.red)),
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
            ],
          ),
        ),
      ),
    );
  }
}
