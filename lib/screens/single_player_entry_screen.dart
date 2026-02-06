import 'package:flutter/material.dart';
import 'package:yazboz/screens/game_settings_screen.dart';

class SinglePlayerEntryScreen extends StatefulWidget {
  const SinglePlayerEntryScreen({super.key});

  @override
  State<SinglePlayerEntryScreen> createState() =>
      _SinglePlayerEntryScreenState();
}

class _SinglePlayerEntryScreenState extends State<SinglePlayerEntryScreen> {
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Oyuncu İsimlerini Girin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        bool isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return Card(
                          elevation: 5,
                          color: isDark ? const Color(0xFF1E1E1E) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _players[index],
                              maxLength: 15,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                icon: Icon(
                                  Icons.person,
                                  color: isDark
                                      ? Colors.green[400]
                                      : Colors.green[800],
                                ),
                                labelText: '${index + 1}. Oyuncu İsmi',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_players.any((c) => c.text.trim().isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lütfen 4 oyuncu ismini de giriniz!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameSettingsScreen(
                            isTeamGame: false,
                            team1Name: _players[0].text.trim(),
                            team2Name: _players[1].text.trim(),
                            player3Name: _players[2].text.trim(),
                            player4Name: _players[3].text.trim(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.deepOrange[900] // Matching New Game
                          : Colors.amber[800],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
