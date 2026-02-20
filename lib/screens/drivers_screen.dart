import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/error_view.dart';
import '../models/driver.dart';
import '../repositories/f1_repository.dart';
import '../services/wikipedia_image_service.dart';
import 'driver_detail_screen.dart';

/// Pantalla de listado de pilotos.
///
/// Carga datos de forma asíncrona y permite navegación al detalle.
class DriversScreen extends StatefulWidget {
  /// Crea la pantalla de pilotos.
  const DriversScreen({super.key, required this.repository});

  /// Repositorio de datos.
  final F1Repository repository;

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

/// Estado interno de [DriversScreen].
class _DriversScreenState extends State<DriversScreen> {
  late Future<List<Driver>> _futureDrivers;
  late final WikipediaImageService _wikiImageService;

  @override
  void initState() {
    super.initState();
    _wikiImageService = WikipediaImageService();
    _futureDrivers = widget.repository.getDrivers();
  }

  @override
  void dispose() {
    _wikiImageService.dispose();
    super.dispose();
  }

  /// Fuerza recarga de pilotos sin bloquear la UI.
  Future<void> _reload() async {
    setState(() {
      _futureDrivers = widget.repository.getDrivers(forceRefresh: true);
    });
    await _futureDrivers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilotos')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Driver>>(
          future: _futureDrivers,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final drivers = snapshot.data ?? const <Driver>[];
            if (drivers.isEmpty) {
              return const Center(child: Text('No drivers available.'));
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: drivers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return ListTile(
                  leading: _DriverAvatar(
                    driver: driver,
                    imageService: _wikiImageService,
                  ),
                  title: Text('${index + 1}. ${driver.name}.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DriverDetailScreen(
                          driver: driver,
                          imageService: _wikiImageService,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Avatar de piloto para la lista, con carga asíncrona de imagen.
class _DriverAvatar extends StatelessWidget {
  /// Crea el avatar de piloto con fallback a icono por defecto.
  const _DriverAvatar({required this.driver, required this.imageService});

  /// Piloto asociado al avatar.
  final Driver driver;

  /// Servicio de resolución y caché de imágenes.
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: imageService.getDriverImageUrl(
        driver.id,
        driver.name,
        wikiUrl: driver.wikiUrl,
      ),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        if (imageUrl == null || imageUrl.isEmpty) {
          return const CircleAvatar(child: Icon(Icons.person));
        }

        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const CircleAvatar(child: Icon(Icons.person)),
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(Icons.person)),
          ),
        );
      },
    );
  }
}
