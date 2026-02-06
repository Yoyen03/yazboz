import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yazboz/screens/scoreboard_screen.dart';
import 'package:yazboz/screens/single_scoreboard_screen.dart';

class GameSettingsScreen extends StatefulWidget {
  final bool isTeamGame;
  final String team1Name;
  final String team2Name;
  final String? player3Name;
  final String? player4Name;

  const GameSettingsScreen({
    super.key,
    required this.isTeamGame,
    required this.team1Name,
    required this.team2Name,
    this.player3Name,
    this.player4Name,
  });

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  double _totalRounds = 7;
  late TextEditingController _thresholdCtrl;
  late TextEditingController _wrongMoveCtrl;

  @override
  void initState() {
    super.initState();
    _thresholdCtrl = TextEditingController(text: "101");
    _wrongMoveCtrl = TextEditingController(text: "101");
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _wrongMoveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Arka planı en dibe kadar gradyanla dolduruyoruz
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.2,
          colors: [Color(0xFF81C784), Color(0xFF1B5E20)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Oyun Ayarları',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  // İçeriği ekranın tam boyuna zorluyoruz
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Elemanları yayıyoruz
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Kısım: Başlık ve Tur Ayarı
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Oyun Kuralları',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildSectionHeader("Toplam El Sayısı"),
                            _buildRoundCard(),
                          ],
                        ),

                        // Orta Kısım: Ceza ve Baraj Ayarları
                        Column(
                          children: [
                            _buildInputRule("Baraj Puanı", _thresholdCtrl),
                            const SizedBox(height: 20),
                            _buildInputRule(
                              "Hatalı Hareket Cezası",
                              _wrongMoveCtrl,
                            ),
                          ],
                        ),

                        // Alt Kısım: Başlat Butonu (Ekranın en altında durur)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildStartButton(context),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) => ElevatedButton(
    onPressed: () {
      int finalThreshold = int.tryParse(_thresholdCtrl.text) ?? 101;
      int finalWrongMove = int.tryParse(_wrongMoveCtrl.text) ?? 101;

      if (widget.isTeamGame) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreboardScreen(
              isTeamGame: true,
              team1Name: widget.team1Name,
              team2Name: widget.team2Name,
              totalRounds: _totalRounds.toInt(),
              threshold: finalThreshold,
              wrongMovePenalty: finalWrongMove,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleScoreboardScreen(
              playerNames: [
                widget.team1Name,
                widget.team2Name,
                widget.player3Name ?? "OYUNCU 3",
                widget.player4Name ?? "OYUNCU 4",
              ],
              totalRounds: _totalRounds.toInt(),
              threshold: finalThreshold,
              wrongMovePenalty: finalWrongMove,
            ),
          ),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.deepOrange[900]
          : Colors.orange[800],
      minimumSize: const Size(
        double.infinity,
        65,
      ), // Butonu biraz daha kalınlaştırdık
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    child: const Text(
      'OYUNU BAŞLAT',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildSectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildRoundCard() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      color: isDark ? const Color(0xFF1E1E1E) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.green[900] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_totalRounds.toInt()}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.green[300] : Colors.green[800],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Slider(
                value: _totalRounds,
                min: 1,
                max: 15,
                divisions: 14,
                activeColor: Colors.orange[800],
                onChanged: (v) => setState(() => _totalRounds = v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRule(String t, TextEditingController c) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              t,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: c,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.green[300] : Colors.green,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: isDark ? Colors.green[900] : Colors.green[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
