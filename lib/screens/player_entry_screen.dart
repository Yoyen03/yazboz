import 'package:flutter/material.dart';
import 'package:yazboz/screens/game_settings_screen.dart';

class PlayerEntryScreen extends StatefulWidget {
  const PlayerEntryScreen({super.key});

  @override
  State<PlayerEntryScreen> createState() => _PlayerEntryScreenState();
}

class _PlayerEntryScreenState extends State<PlayerEntryScreen> {
  final TextEditingController _team1 = TextEditingController();
  final TextEditingController _team2 = TextEditingController();
  final List<TextEditingController> _players = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [Color(0xFF81C784), Color(0xFF1B5E20)],
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/pinstriped-suit.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'Ekipleri Belirleyin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTeamCard(
                          "1. EKİP",
                          _team1,
                          _players[0],
                          _players[1],
                          Colors.blue[800]!,
                        ),
                        const Text(
                          "VS",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildTeamCard(
                          "2. EKİP",
                          _team2,
                          _players[2],
                          _players[3],
                          Colors.red[800]!,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameSettingsScreen(
                              isTeamGame: true,
                              // BURASI YENİ: İsimleri bir sonraki sayfaya paketliyoruz
                              team1Name: _team1.text.isEmpty
                                  ? "1. EKİP"
                                  : _team1.text,
                              team2Name: _team2.text.isEmpty
                                  ? "2. EKİP"
                                  : _team2.text,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'DEVAM ET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    String title,
    TextEditingController team,
    TextEditingController p1,
    TextEditingController p2,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            _input(team, "Ekip İsmi", Icons.group, color),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _input(p1, "1. Oyuncu", Icons.person, color)),
                const SizedBox(width: 8),
                Expanded(
                  child: _input(p2, "2. Oyuncu", Icons.person_outline, color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String lbl,
    IconData icon,
    Color color,
  ) {
    return TextField(
      controller: ctrl,
      maxLength: 15,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        counterText: "",
        labelText: lbl,
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(icon, color: color, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
