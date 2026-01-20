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
                      children: List.generate(
                        4,
                        (index) => Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: _players[index],
                              maxLength: 15,
                              decoration: InputDecoration(
                                counterText: "",
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.green[800],
                                ),
                                labelText: '${index + 1}. Oyuncu İsmi',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameSettingsScreen(
                            isTeamGame: false,
                            // BURASI YENİ: Oyuncu isimlerini gönderiyoruz
                            team1Name: _players[0].text.isEmpty
                                ? "OYUNCU 1"
                                : _players[0].text,
                            team2Name: _players[1].text.isEmpty
                                ? "OYUNCU 2"
                                : _players[1].text,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
