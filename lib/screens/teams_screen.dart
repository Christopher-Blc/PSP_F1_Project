import 'package:flutter/material.dart';

import '../components/error_view.dart';
import '../components/information_card.dart';
import '../models/team.dart';
import '../repositories/f1_repository.dart';

/// Pantalla de equipos de la temporada actual.
class TeamsScreen extends StatefulWidget {
  /// Crea la pantalla de equipos.
  const TeamsScreen({super.key, required this.repository});

  /// Repositorio de datos.
  final F1Repository repository;

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

/// Estado interno de [TeamsScreen].
class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<Team>> _futureTeams;

  @override
  void initState() {
    super.initState();
    _futureTeams = widget.repository.getTeams();
  }

  /// Recarga la lista de equipos de forma asíncrona.
  Future<void> _reload() async {
    setState(() {
      _futureTeams = widget.repository.getTeams(forceRefresh: true);
    });
    await _futureTeams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipos')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Team>>(
          future: _futureTeams,
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

            final teams = snapshot.data ?? const <Team>[];
            if (teams.isEmpty) {
              return const Center(child: Text('No teams available.'));
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                            InformationCard(label: 'ID', value: team.id),
                            InformationCard(
                              label: 'Country',
                              value: team.country ?? '-',
                            ),
                          ],
                        ),
                        if (team.wikiUrl != null &&
                            team.wikiUrl!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 10),
                          Text(
                            team.wikiUrl!,
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
