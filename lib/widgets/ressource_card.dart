import 'package:flutter/material.dart';
import '../models/ressource.dart';
import '../services/ressource_service.dart';

class RessourceCard extends StatefulWidget {
  final Ressource ressource;
  const RessourceCard({super.key, required this.ressource});

  @override
  State<RessourceCard> createState() => _RessourceCardState();
}

class _RessourceCardState extends State<RessourceCard> {
  String? auteur;
  final RessourceService _ressourceService = RessourceService();

  @override
  void initState() {
    super.initState();
    _loadAuteur();
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
                      Icon(Icons.thumb_up,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${widget.ressource.nbLike}'),
                      const SizedBox(width: 12),
                      Icon(Icons.comment,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${widget.ressource.nbCom}'),
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
