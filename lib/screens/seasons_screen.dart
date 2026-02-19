import 'package:flutter/material.dart';

import '../components/error_view.dart';
import '../components/information_card.dart';
import '../models/season.dart';
import '../repositories/f1_repository.dart';

/// Pantalla de temporadas históricas.
class SeasonsScreen extends StatefulWidget {
  /// Crea la pantalla de temporadas.
  const SeasonsScreen({super.key, required this.repository});

  /// Repositorio de datos.
  final F1Repository repository;

  @override
  State<SeasonsScreen> createState() => _SeasonsScreenState();
}

/// Estado interno de [SeasonsScreen].
class _SeasonsScreenState extends State<SeasonsScreen> {
  late Future<List<Season>> _futureSeasons;

  @override
  void initState() {
    super.initState();
    _futureSeasons = widget.repository.getSeasons();
  }

  /// Recarga la lista de temporadas de forma asíncrona.
  Future<void> _reload() async {
    setState(() {
      _futureSeasons = widget.repository.getSeasons(forceRefresh: true);
    });
    await _futureSeasons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seasons')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Season>>(
          future: _futureSeasons,
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

            final seasons = snapshot.data ?? const <Season>[];
            if (seasons.isEmpty) {
              return const Center(child: Text('No seasons available.'));
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: seasons.length,
              itemBuilder: (context, index) {
                final season = seasons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const CircleAvatar(
                              child: Icon(Icons.calendar_today),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Season ${season.year}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        InformationCard(
                          label: 'Year',
                          value: season.year.toString(),
                        ),
                        if (season.wikiUrl != null &&
                            season.wikiUrl!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 10),
                          Text(
                            season.wikiUrl!,
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
