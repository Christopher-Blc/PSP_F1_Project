import 'package:flutter/material.dart';

import '../components/error_view.dart';
import '../components/information_card.dart';
import '../models/circuit.dart';
import '../repositories/f1_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _futureCircuits = widget.repository.getCircuits();
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

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: circuits.length,
              itemBuilder: (context, index) {
                final circuit = circuits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                          const SizedBox(height: 10),
                          Text(
                            circuit.wikiUrl!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
