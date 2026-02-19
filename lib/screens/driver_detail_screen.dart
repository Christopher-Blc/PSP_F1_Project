import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/information_card.dart';
import '../models/driver.dart';
import '../services/wikipedia_image_service.dart';

/// Pantalla de detalle de un piloto.
class DriverDetailScreen extends StatelessWidget {
  /// Crea la vista de detalle del [driver] seleccionado.
  const DriverDetailScreen({
    super.key,
    required this.driver,
    required this.imageService,
  });

  /// Entidad de piloto a mostrar.
  final Driver driver;

  /// Servicio que resuelve y cachea la imagen del piloto.
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(driver.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          FutureBuilder<String?>(
            future: imageService.getDriverImageUrl(driver.id, driver.name),
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
                  child: const Center(child: Icon(Icons.person, size: 80)),
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
                          child: Icon(Icons.person, size: 80),
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
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          driver.name,
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
                      InformationCard(label: 'ID', value: driver.id),
                      InformationCard(
                        label: 'Número',
                        value: driver.number?.toString() ?? '-',
                      ),
                      InformationCard(
                        label: 'Código',
                        value: driver.code ?? '-',
                      ),
                      InformationCard(
                        label: 'País',
                        value: driver.country ?? '-',
                      ),
                      InformationCard(
                        label: 'Nacimiento',
                        value: driver.birthDate ?? '-',
                      ),
                    ],
                  ),
                  if (driver.wikiUrl != null &&
                      driver.wikiUrl!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      driver.wikiUrl!,
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
