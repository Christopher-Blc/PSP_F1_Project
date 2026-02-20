import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/error_view.dart';
import '../models/team.dart';
import '../repositories/f1_repository.dart';
import '../services/wikipedia_image_service.dart';
import 'team_detail_screen.dart';

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
  late final WikipediaImageService _wikiImageService;

  @override
  void initState() {
    super.initState();
    _wikiImageService = WikipediaImageService();
    _futureTeams = widget.repository.getTeams();
  }

  @override
  void dispose() {
    _wikiImageService.dispose();
    super.dispose();
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

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: teams.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final team = teams[index];
                return ListTile(
                  leading: _TeamAvatar(
                    team: team,
                    imageService: _wikiImageService,
                  ),
                  title: Text('${index + 1}. ${team.name}.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TeamDetailScreen(
                          team: team,
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

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team, required this.imageService});

  final Team team;
  final WikipediaImageService imageService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: imageService.getTeamImageUrl(
        team.id,
        team.name,
        wikiUrl: team.wikiUrl,
      ),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        if (imageUrl == null || imageUrl.isEmpty) {
          return const CircleAvatar(child: Icon(Icons.groups));
        }

        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const CircleAvatar(child: Icon(Icons.groups)),
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(Icons.groups)),
          ),
        );
      },
    );
  }
}
