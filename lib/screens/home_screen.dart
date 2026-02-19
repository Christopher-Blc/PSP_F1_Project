import 'package:flutter/material.dart';

/// Pantalla principal de navegación.
class HomeScreen extends StatelessWidget {
  /// Crea la pantalla de inicio con callbacks por sección.
  const HomeScreen({
    super.key,
    required this.onDriversTap,
    required this.onTeamsTap,
    required this.onCircuitsTap,
    required this.onSeasonsTap,
  });

  /// Acción al pulsar el botón de pilotos.
  final VoidCallback onDriversTap;

  /// Acción al pulsar el botón de equipos.
  final VoidCallback onTeamsTap;

  /// Acción al pulsar el botón de circuitos.
  final VoidCallback onCircuitsTap;

  /// Acción al pulsar el botón de temporadas.
  final VoidCallback onSeasonsTap;

  @override
  Widget build(BuildContext context) {
    const menuItems = <({String label, IconData icon, Color color})>[
      (label: 'Drivers', icon: Icons.person, color: Color(0xFFE10600)),
      (label: 'Teams', icon: Icons.groups, color: Color(0xFFB00000)),
      (label: 'Circuits', icon: Icons.route, color: Color(0xFF8D0000)),
      (label: 'Seasons', icon: Icons.calendar_today, color: Color(0xFF5C1010)),
    ];

    final actions = <VoidCallback>[
      onDriversTap,
      onTeamsTap,
      onCircuitsTap,
      onSeasonsTap,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('F1 Dashboard')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF000000), Color(0xFF15161A)],
            stops: <double>[0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Formula 1 Data Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Choose a section to explore current championship data.',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (int i = 0; i < menuItems.length; i++) ...<Widget>[
                  _MainMenuButton(
                    label: menuItems[i].label,
                    icon: menuItems[i].icon,
                    color: menuItems[i].color,
                    onPressed: actions[i],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón reutilizable del menú principal.
class _MainMenuButton extends StatelessWidget {
  /// Crea un botón de menú grande con icono y texto.
  const _MainMenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  /// Texto del botón.
  final String label;

  /// Icono del botón.
  final IconData icon;

  /// Color principal del botón.
  final Color color;

  /// Acción al pulsar.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: <Color>[color, Color.lerp(color, Colors.black, 0.2)!],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}
