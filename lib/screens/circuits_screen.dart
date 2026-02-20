import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/error_view.dart';
import '../models/circuit.dart';
import '../repositories/f1_repository.dart';
import '../services/wikipedia_image_service.dart';
import 'circuit_detail_screen.dart';

/// Pantalla de circuitos de la temporada actual.
class CircuitsScreen extends StatefulWidget {
  /// Crea la pantalla de circuitos.
  const CircuitsScreen({super.key, required this.repository});

  /// Repositorio de datos.
  final F1Repository repository;

  @override
  State<CircuitsScreen> createState() => _CircuitsScreenState();
}

/// Estado interno de [CircuitsScreen].
class _CircuitsScreenState extends State<CircuitsScreen> {
  late Future<List<Circuit>> _futureCircuits;
  late final WikipediaImageService _wikiImageService;

  @override
  void initState() {
    super.initState();
    _wikiImageService = WikipediaImageService();
    _futureCircuits = widget.repository.getCircuits();
  }

  @override
  void dispose() {
    _wikiImageService.dispose();
    super.dispose();
  }

  /// Recarga la lista de circuitos de forma asíncrona.
  Future<void> _reload() async {
    setState(() {
      _futureCircuits = widget.repository.getCircuits(forceRefresh: true);
    });
    await _futureCircuits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circuitos')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Circuit>>(
          future: _futureCircuits,
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

            final circuits = snapshot.data ?? const <Circuit>[];
            if (circuits.isEmpty) {
              return const Center(child: Text('No hay circuitos disponibles.'));
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: circuits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final circuit = circuits[index];
                return ListTile(
                  leading: _CircuitAvatar(
                    circuit: circuit,
                    imageService: _wikiImageService,
                  ),
                  title: Text('${index + 1}. ${circuit.name}.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CircuitDetailScreen(
                          circuit: circuit,
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

class _CircuitAvatar extends StatelessWidget {
  const _CircuitAvatar({required this.circuit, required this.imageService});

  final Circuit circuit;
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: imageService.getCircuitImageUrl(
        circuit.id,
        circuit.name,
        wikiUrl: circuit.wikiUrl,
      ),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        if (imageUrl == null || imageUrl.isEmpty) {
          return const CircleAvatar(child: Icon(Icons.route));
        }

        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const CircleAvatar(child: Icon(Icons.route)),
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(Icons.route)),
          ),
        );
      },
    );
  }
}
