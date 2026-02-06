import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_entry_screen.dart';
import 'single_player_entry_screen.dart';
import 'scoreboard_screen.dart';
import 'single_scoreboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSavedGame =
          prefs.getBool('hasSavedGameS') == true ||
          prefs.getBool('hasSavedGameSS') == true;
    });
  }

  Future<void> _resumeGame() async {
    final prefs = await SharedPreferences.getInstance();
    bool isTeam = prefs.getBool('isTeamGame') ?? false;

    if (isTeam) {
      String t1 = prefs.getString('team1Name') ?? "TAKIM 1";
      String t2 = prefs.getString('team2Name') ?? "TAKIM 2";
      int tr = prefs.getInt('totalRounds') ?? 11;
      int th = prefs.getInt('threshold') ?? 0;
      int wp = prefs.getInt('wrongMovePenalty') ?? 50;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreboardScreen(
            isTeamGame: true,
            team1Name: t1,
            team2Name: t2,
            totalRounds: tr,
            threshold: th,
            wrongMovePenalty: wp,
            isResumed: true,
          ),
        ),
      );
    } else {
      List<String> names =
          prefs.getStringList('playerNames') ?? ["1", "2", "3", "4"];
      int tr = prefs.getInt('totalRounds') ?? 11;
      int th = prefs.getInt('threshold') ?? 0;
      int wp = prefs.getInt('wrongMovePenalty') ?? 50;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SingleScoreboardScreen(
            playerNames: names,
            totalRounds: tr,
            threshold: th,
            wrongMovePenalty: wp,
            isResumed: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/okey_arka_plan.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF1B5E20)),
                ),
                if (widget.isDarkMode)
                  Container(color: Colors.black.withOpacity(0.2)),
              ],
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.grey[800]!.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: widget.isDarkMode
                              ? Colors.yellow
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 30, // Tuş boyutunu sınırlıyoruz
                          child: Switch(
                            value: widget.isDarkMode,
                            onChanged: widget.onThemeChanged,
                            activeColor: Colors.blue,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ), // Başlık ile üst kısım arasını açtık
                      Text(
                        'YAZ-BOZ',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: widget.isDarkMode
                              ? Colors.amber[400]
                              : Colors.amber[700],
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              blurRadius: 15.0,
                              color: widget.isDarkMode
                                  ? Colors.white24
                                  : Colors.black,
                              offset: const Offset(4.0, 4.0),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // --- ANA MENÜ BUTONLARI ---
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _showModeSelection(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDarkMode
                                    ? Colors.deepOrange[900] // Darker One
                                    : Colors.amber[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              child: const Text(
                                'YENİ OYUN',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (_hasSavedGame) ...[
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _resumeGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isDarkMode
                                      ? Colors.green[900] // Darker Green
                                      : Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 60,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 10,
                                ),
                                child: const Text(
                                  'DEVAM ET',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "OYUN MODU SEÇ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 25),
            _modeButton(
              context,
              "EŞLİ OYUN",
              Icons.groups,
              widget.isDarkMode ? Colors.blue[300]! : Colors.blue[800]!,
              const PlayerEntryScreen(),
            ),
            const SizedBox(height: 12),
            _modeButton(
              context,
              "TEKLİ OYUN",
              Icons.person,
              widget.isDarkMode ? Colors.orange[300]! : Colors.orange[800]!,
              const SinglePlayerEntryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget target,
  ) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      tileColor: widget.isDarkMode ? Colors.white.withOpacity(0.05) : null,
    );
  }
}
