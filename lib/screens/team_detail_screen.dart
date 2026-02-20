import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../components/information_card.dart';
import '../models/team.dart';
import '../services/wikipedia_image_service.dart';

/// Pantalla de detalle de un equipo.
class TeamDetailScreen extends StatelessWidget {
  /// Crea la vista de detalle del [team] seleccionado.
  const TeamDetailScreen({
    super.key,
    required this.team,
    required this.imageService,
  });

  /// Entidad de equipo a mostrar.
  final Team team;

  /// Servicio que resuelve y cachea la imagen del equipo.
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          FutureBuilder<String?>(
            future: imageService.getTeamImageUrl(
              team.id,
              team.name,
              wikiUrl: team.wikiUrl,
            ),
            builder: (context, snapshot) {
              final imageUrl = snapshot.data;

              if (imageUrl == null || imageUrl.isEmpty) {
                return Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(Icons.groups, size: 80)),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: Container(
                    color: Colors.black,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.groups, size: 80),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const CircleAvatar(child: Icon(Icons.groups)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          team.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      InformationCard(label: 'ID', value: team.id),
                      InformationCard(
                        label: 'Country',
                        value: team.country ?? '-',
                      ),
                    ],
                  ),
                  if (team.wikiUrl != null &&
                      team.wikiUrl!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      team.wikiUrl!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
