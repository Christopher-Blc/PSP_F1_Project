import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../components/information_card.dart';
import '../models/circuit.dart';
import '../services/wikipedia_image_service.dart';

/// Pantalla de detalle de un circuito.
class CircuitDetailScreen extends StatelessWidget {
  /// Crea la vista de detalle del [circuit] seleccionado.
  const CircuitDetailScreen({
    super.key,
    required this.circuit,
    required this.imageService,
  });

  /// Entidad de circuito a mostrar.
  final Circuit circuit;

  /// Servicio que resuelve y cachea la imagen del circuito.
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(circuit.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          FutureBuilder<String?>(
            future: imageService.getCircuitImageUrl(
              circuit.id,
              circuit.name,
              wikiUrl: circuit.wikiUrl,
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
                  child: const Center(child: Icon(Icons.route, size: 80)),
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
                        child: const Center(child: Icon(Icons.route, size: 80)),
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
                      const CircleAvatar(child: Icon(Icons.route)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          circuit.name,
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
                      InformationCard(label: 'ID', value: circuit.id),
                      InformationCard(
                        label: 'Ciudad',
                        value: circuit.city ?? '-',
                      ),
                      InformationCard(
                        label: 'País',
                        value: circuit.country ?? '-',
                      ),
                      InformationCard(
                        label: 'Lat',
                        value: circuit.latitude ?? '-',
                      ),
                      InformationCard(
                        label: 'Long',
                        value: circuit.longitude ?? '-',
                      ),
                    ],
                  ),
                  if (circuit.wikiUrl != null &&
                      circuit.wikiUrl!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      circuit.wikiUrl!,
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
