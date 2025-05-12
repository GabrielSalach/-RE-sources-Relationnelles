import 'package:flutter/material.dart';
import '../models/ressource.dart';
import '../services/ressource_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import '../pages/profil_public_page.dart';
import 'commentaires_section.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

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
  bool isFavoriLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuteur();
    nbLike = widget.ressource.nbLike;
    nbReport = widget.ressource.nbReport;
    _initStates();
  }

  Future<void> _initStates() async {
    print('_initStates - Début de l\'initialisation');
    final authState = context.read<AppAuthState>();
    final currentUser = authState.currentUser;

    if (currentUser == null) {
      print('_initStates - Pas d\'utilisateur connecté');
      return;
    }

    try {
      final intId = int.parse(currentUser.id);
      print('_initStates - Vérification des états pour l\'utilisateur $intId');

      final liked =
          await _ressourceService.hasLiked(widget.ressource.id, intId);
      print('_initStates - hasLiked: $liked');

      final favori = await _ressourceService.isRessourceFavorite(
          widget.ressource.id, intId);
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
        contenuWidget = widget.ressource.getDisplayUrl() != null
            ? Image.network(
                widget.ressource.getDisplayUrl()!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )
            : const Icon(Icons.broken_image);
        break;
      case 3:
        contenuWidget = Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(url: widget.ressource.contenue),
            ),
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
                                  child: VideoPlayerWidget(
                                      url: widget.ressource.contenue),
                                ),
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
                  onPressed: () async {
                    final authState = context.read<AppAuthState>();
                    final currentUser = authState.currentUser;

                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez être connecté pour liker'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isLiked = !isLiked;
                    });
                    try {
                      final intId = int.parse(currentUser.id);
                      if (isLiked) {
                        await _ressourceService.likeRessource(
                            widget.ressource.id, intId);
                      } else {
                        await _ressourceService.unlikeRessource(
                            widget.ressource.id, intId);
                      }
                      await _refreshNbLike();
                    } catch (e) {
                      print('Erreur lors du like: $e');
                      setState(() {
                        isLiked =
                            !isLiked; // Annuler le changement en cas d'erreur
                      });
                    }
                  },
                ),
                Text('$nbLike'),
                const SizedBox(width: 8),
                _buildActions(context),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.flag,
                    color: isSignaled ? Colors.red : Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: isSignaled ? 'Déjà signalé' : 'Signaler',
                  onPressed: () {
                    final authState = context.read<AppAuthState>();
                    final currentUser = authState.currentUser;

                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Vous devez être connecté pour signaler'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (isSignaled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Vous avez déjà signalé cette ressource'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez indiquer un motif'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              try {
                                final intId = int.parse(currentUser.id);
                                await _ressourceService.signalerRessource(
                                  widget.ressource.id,
                                  intId,
                                  motifController.text.trim(),
                                );
                                setState(() {
                                  isSignaled = true;
                                  nbReport++;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ressource signalée'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                print('Erreur lors du signalement: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erreur lors du signalement'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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

  Widget _buildActions(BuildContext context) {
    final authState = context.watch<AppAuthState>();
    final userId = authState.currentUser?.id;

    if (userId == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton Favori existant
        FutureBuilder<bool>(
          future: _ressourceService.isRessourceFavorite(
              widget.ressource.id, int.parse(userId)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final isFavorite = snapshot.data!;
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : null,
              ),
              onPressed: () async {
                if (isFavorite) {
                  await _ressourceService.removeFavori(
                      widget.ressource.id, int.parse(userId));
                } else {
                  await _ressourceService.addFavori(
                      widget.ressource.id, int.parse(userId));
                }
                setState(() {});
              },
            );
          },
        ),

        // Bouton Exploitée
        FutureBuilder<bool>(
          future: _ressourceService.isRessourceExploitee(
              widget.ressource.id, int.parse(userId)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final isExploitee = snapshot.data!;
            return IconButton(
              icon: Icon(
                isExploitee ? Icons.check_circle : Icons.check_circle_outline,
                color: isExploitee ? Colors.green : null,
              ),
              onPressed: () async {
                if (isExploitee) {
                  await _ressourceService.deMarquerRessourceExploitee(
                      widget.ressource.id, int.parse(userId));
                } else {
                  await _ressourceService.marquerRessourceExploitee(
                      widget.ressource.id, int.parse(userId));
                }
                setState(() {});
              },
              tooltip: isExploitee
                  ? 'Marquer comme non consultée'
                  : 'Marquer comme consultée',
            );
          },
        ),

        // Bouton Mise de côté
        FutureBuilder<bool>(
          future: _ressourceService.isRessourceMiseDeCote(
              widget.ressource.id, int.parse(userId)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final isMiseDeCote = snapshot.data!;
            return IconButton(
              icon: Icon(
                isMiseDeCote ? Icons.bookmark : Icons.bookmark_border,
                color: isMiseDeCote ? Colors.blue : null,
              ),
              onPressed: () async {
                if (isMiseDeCote) {
                  await _ressourceService.deMarquerRessourceMiseDeCote(
                      widget.ressource.id, int.parse(userId));
                } else {
                  await _ressourceService.marquerRessourceMiseDeCote(
                      widget.ressource.id, int.parse(userId));
                }
                setState(() {});
              },
              tooltip: isMiseDeCote
                  ? 'Retirer des ressources à voir'
                  : 'Marquer à voir plus tard',
            );
          },
        ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late YoutubePlayerController _youtubeController;
  bool isYoutubeVideo = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    isYoutubeVideo = YoutubePlayer.convertUrlToId(widget.url) != null;

    if (isYoutubeVideo) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleTap() {
    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (!isYoutubeVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isYoutubeVideo) {
      return YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _handleTap,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (_showControls)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                          _startHideTimer();
                        }
                      });
                    },
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
