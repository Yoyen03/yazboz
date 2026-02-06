import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreboardScreen extends StatefulWidget {
  final bool isTeamGame;
  final String team1Name;
  final String team2Name;
  final int totalRounds;
  final int threshold;
  final int wrongMovePenalty;
  final bool isResumed;

  const ScoreboardScreen({
    super.key,
    required this.isTeamGame,
    required this.team1Name,
    required this.team2Name,
    required this.totalRounds,
    required this.threshold,
    required this.wrongMovePenalty,
    this.isResumed = false,
  });

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final ScrollController _s1Controller = ScrollController();
  final ScrollController _s2Controller = ScrollController();
  List<int> team1RoundPenalties = [];
  List<int> team2RoundPenalties = [];
  List<int> team1History = [];
  List<int> team2History = [];
  int currentRound = 1;
  bool _showTotalScores = false;

  bool get isGameOver => currentRound > widget.totalRounds;

  void _showWinnerDialog(int t1, int t2) {
    String winnerName = t1 < t2 ? widget.team1Name : widget.team2Name;
    bool isDraw = (t1 == t2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "🏆 OYUN BİTTİ",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDraw ? "DOSTLUK KAZANDI" : "ŞAMPİYON: $winnerName",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Text("${widget.team1Name}: $t1"),
            Text("${widget.team2Name}: $t2"),
          ],
        ),
        actions: [
          Column(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "SONUÇLARI İNCELE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  "ANA SAYFAYA DÖN",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScoreEntry() {
    final t1 = TextEditingController();
    final t2 = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "EL: $currentRound PUAN GİRİŞİ",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: t1,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: "${widget.team1Name} PUANI",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: t2,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: "${widget.team2Name} PUANI",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int s1 = int.tryParse(t1.text) ?? 0;
                  int s2 = int.tryParse(t2.text) ?? 0;
                  team1History.add(
                    s1 + team1RoundPenalties.fold(0, (a, b) => a + b),
                  );
                  team2History.add(
                    s2 + team2RoundPenalties.fold(0, (a, b) => a + b),
                  );
                  team1RoundPenalties.clear();
                  team2RoundPenalties.clear();

                  if (currentRound >= widget.totalRounds) {
                    int f1 = team1History.fold(0, (a, b) => a + b);
                    int f2 = team2History.fold(0, (a, b) => a + b);
                    currentRound++;
                    _saveGame();
                    // _clearSave kaldırıldı
                    Navigator.pop(context);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _showWinnerDialog(f1, f2),
                    );
                  } else {
                    currentRound++;
                    _saveGame();
                    Navigator.pop(context);

                    // 1 el kala (Son el öncesi) otomatik fark göster
                    if (currentRound == widget.totalRounds) {
                      Future.delayed(
                        const Duration(milliseconds: 500),
                        _showDifferenceDialog,
                      );
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "KAYDET",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addPenalty(int idx, int val) {
    if (!isGameOver) {
      setState(() {
        if (idx == 1) {
          team1RoundPenalties.add(val);
          _scrollToBottom(_s1Controller);
        } else {
          team2RoundPenalties.add(val);
          _scrollToBottom(_s2Controller);
        }
      });
    }
  }

  void _scrollToBottom(ScrollController c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.hasClients)
        c.animateTo(
          c.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  void _showCustomInput(int idx) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Puan Gir"),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
          ],
          autofocus: true,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty && ctrl.text != "-")
                _addPenalty(idx, int.parse(ctrl.text));
              Navigator.pop(context);
            },
            child: const Text("EKLE"),
          ),
        ],
      ),
    );
  }

  void _showPenaltyMenu(int idx) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.shield, color: Colors.orange),
            title: const Text("Baraj Cezası"),
            trailing: Text("+${widget.threshold}"),
            onTap: () {
              _addPenalty(idx, widget.threshold);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text("Hatalı Hareket"),
            trailing: Text("+${widget.wrongMovePenalty}"),
            onTap: () {
              _addPenalty(idx, widget.wrongMovePenalty);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Özel Puan (Eksi Girilebilir)"),
            onTap: () {
              Navigator.pop(context);
              _showCustomInput(idx);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isResumed) {
      _loadGame();
    } else {
      _saveGame(); // Yeni oyun başladı, hemen kaydet
    }
  }

  // --- OYUN KAYDEDİCİ ---
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSavedGameS', true);
    await prefs.setBool('isTeamGame', true);
    await prefs.setString('team1Name', widget.team1Name);
    await prefs.setString('team2Name', widget.team2Name);
    await prefs.setInt('totalRounds', widget.totalRounds);
    await prefs.setInt('threshold', widget.threshold);
    await prefs.setInt('wrongMovePenalty', widget.wrongMovePenalty);

    // Geçici değişkenler
    await prefs.setInt('currentRound', currentRound);
    await prefs.setString('team1History', team1History.join(','));
    await prefs.setString('team2History', team2History.join(','));
    await prefs.setString('team1RoundPenalties', team1RoundPenalties.join(','));
    await prefs.setString('team2RoundPenalties', team2RoundPenalties.join(','));
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasSavedGameS') == true &&
        prefs.getBool('isTeamGame') == true) {
      if (prefs.getString('team1Name') == widget.team1Name &&
          prefs.getString('team2Name') == widget.team2Name) {
        setState(() {
          currentRound = prefs.getInt('currentRound') ?? 1;

          String t1h = prefs.getString('team1History') ?? "";
          if (t1h.isNotEmpty) {
            team1History = t1h.split(',').map((e) => int.parse(e)).toList();
          }

          String t2h = prefs.getString('team2History') ?? "";
          if (t2h.isNotEmpty) {
            team2History = t2h.split(',').map((e) => int.parse(e)).toList();
          }

          String t1p = prefs.getString('team1RoundPenalties') ?? "";
          if (t1p.isNotEmpty) {
            team1RoundPenalties = t1p
                .split(',')
                .map((e) => int.parse(e))
                .toList();
          }

          String t2p = prefs.getString('team2RoundPenalties') ?? "";
          if (t2p.isNotEmpty) {
            team2RoundPenalties = t2p
                .split(',')
                .map((e) => int.parse(e))
                .toList();
          }
        });
      }
    }
  }

  // --- GERİ AL (SON ELİ SİL) ---
  void _undoLastRound() {
    if (currentRound <= 1 && team1History.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Son Eli Sil?"),
        content: const Text(
          "Bu işlem son girilen puanları ve biten eli geri alır. Onaylıyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İPTAL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              setState(() {
                if (team1History.isNotEmpty) team1History.removeLast();
                if (team2History.isNotEmpty) team2History.removeLast();
                if (currentRound > 1) currentRound--;
              });
              _saveGame();
            },
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int t1 = team1History.fold(0, (a, b) => a + b);
    int t2 = team2History.fold(0, (a, b) => a + b);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor = isDark ? Colors.grey[700]! : Colors.black;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGameOver
              ? "OYUN BİTTİ"
              : "EL: $currentRound / ${widget.totalRounds}",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: "Fark Hesapla",
            onPressed: _showDifferenceDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  widget.team1Name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  widget.team2Name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _s1Controller,
                      itemCount: team1RoundPenalties.length,
                      itemBuilder: (context, i) => Text(
                        "${team1RoundPenalties[i]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  Container(width: 1.5, color: borderColor),
                  Expanded(
                    child: ListView.builder(
                      controller: _s2Controller,
                      itemCount: team2RoundPenalties.length,
                      itemBuilder: (context, i) => Text(
                        "${team2RoundPenalties[i]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isGameOver ? null : () => _showPenaltyMenu(1),
                  child: const Text("CEZA EKLE"),
                ),
                ElevatedButton(
                  onPressed: isGameOver ? null : () => _showPenaltyMenu(2),
                  child: const Text("CEZA EKLE"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: team1History.length,
                        itemBuilder: (context, i) => Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "${team1History[i]}",
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 45,
                              color: borderColor,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "${team2History[i]}",
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      color: isDark ? Colors.grey[800] : Colors.black12,
                      child: Text(
                        "EL: ${isGameOver ? widget.totalRounds : currentRound} / ${widget.totalRounds}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 160),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFooter(t1, t2),
    );
  }

  Widget _buildFooter(int t1, int t2) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.deepOrange[900]!;
    Color buttonColor = isDark ? Colors.deepOrange[900]! : Colors.deepOrange;

    Color containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: containerColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showTotalScores)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey : Colors.black,
                  width: 2,
                ),
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: isDark ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "TOPLAM",
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            "$t1",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 16, // Reduced size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "TOPLAM",
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            "$t2",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 16, // Reduced size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 5),
          if (_showTotalScores)
            Center(
              child: _utilBtn(
                "GİZLE",
                () => setState(() => _showTotalScores = false),
                Icons.visibility_off,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _utilBtn("ZAR AT", _rollDice, Icons.casino),
                _utilBtn("GERİ AL", _undoLastRound, Icons.undo),
                _utilBtn(
                  "SKOR",
                  () => setState(() => _showTotalScores = true),
                  Icons.visibility,
                ),
              ],
            ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: isGameOver
                ? () => _showWinnerDialog(t1, t2)
                : _showScoreEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: isGameOver ? Colors.orange[800] : buttonColor,
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Text(
              isGameOver ? "SONUÇLARI GÖSTER" : "$currentRound. EL SKORUNU GİR",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _utilBtn(String t, VoidCallback p, IconData i) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: p,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.deepOrange,
        side: BorderSide(color: isDark ? Colors.grey : Colors.grey[300]!),
      ),
      icon: Icon(i, size: 14),
      label: Text(t, style: const TextStyle(fontSize: 10)),
    );
  }

  // --- ZAR ATMA (ANİMASYONLU) ---
  void _rollDice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DiceRollDialog(),
    );
  }

  // --- FARK HESAPLAMA ---
  void _showDifferenceDialog() {
    int t1 = team1History.fold(0, (a, b) => a + b);
    int t2 = team2History.fold(0, (a, b) => a + b);
    int leaderScore = t1 < t2 ? t1 : t2;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PUAN FARKLARI (Lider'e Göre)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(widget.team1Name),
              trailing: Text(
                t1 == leaderScore ? "LİDER" : "+${t1 - leaderScore}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: t1 == leaderScore ? Colors.green : Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              title: Text(widget.team2Name),
              trailing: Text(
                t2 == leaderScore ? "LİDER" : "+${t2 - leaderScore}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: t2 == leaderScore ? Colors.green : Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }
}

class _DiceRollDialog extends StatefulWidget {
  const _DiceRollDialog();

  @override
  State<_DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<_DiceRollDialog> {
  int d1 = 1;
  int d2 = 1;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < 15; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        d1 = (DateTime.now().microsecondsSinceEpoch % 6) + 1;
        d2 = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
      });
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.pop(context);

    // Sonucu göster
    if (mounted) {
      _showResult(d1, d2);
    }
  }

  void _showResult(int f1, int f2) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ZAR SONUCU",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDiceIcon(f1, isDark),
                const SizedBox(width: 20),
                _buildDiceIcon(f2, isDark),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "$f1 - $f2",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceIcon(int val, bool isDark) {
    IconData icon;
    switch (val) {
      case 1:
        icon = Icons.looks_one;
        break;
      case 2:
        icon = Icons.looks_two;
        break;
      case 3:
        icon = Icons.looks_3;
        break;
      case 4:
        icon = Icons.looks_4;
        break;
      case 5:
        icon = Icons.looks_5;
        break;
      case 6:
        icon = Icons.looks_6;
        break;
      default:
        icon = Icons.help;
    }
    return Icon(
      icon,
      size: 60,
      color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                size: 80,
                color: Colors.white,
              ), // Basit animasyon ikonu
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Zarlar Atılıyor...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
