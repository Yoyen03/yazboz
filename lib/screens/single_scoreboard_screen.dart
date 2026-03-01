import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SingleScoreboardScreen extends StatefulWidget {
  final List<String> playerNames;
  final int totalRounds;
  final int threshold;
  final int wrongMovePenalty;
  final bool isResumed;

  const SingleScoreboardScreen({
    super.key,
    required this.playerNames,
    required this.totalRounds,
    required this.threshold,
    required this.wrongMovePenalty,
    this.isResumed = false,
  });

  @override
  State<SingleScoreboardScreen> createState() => _SingleScoreboardScreenState();
}

class _SingleScoreboardScreenState extends State<SingleScoreboardScreen> {
  final List<ScrollController> _controllers = List.generate(
    4,
    (_) => ScrollController(),
  );
  List<List<int>> pCurrentPenalties = List.generate(4, (_) => []);
  List<List<int>> pHistory = List.generate(4, (_) => []);
  int currentRound = 1;
  bool _showTotalScores = false;

  bool get isGameOver => currentRound > widget.totalRounds;

  // --- ZAR ATMA (ANİMASYONLU) ---
  void _rollDice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DiceRollDialog(),
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

  void _showWinnerDialog(List<int> totals) {
    int minScore = totals.reduce(min);
    int winnerIdx = totals.indexOf(minScore);
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
              "ŞAMPİYON: ${widget.playerNames[winnerIdx]}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              4,
              (i) => Text(
                "${widget.playerNames[i]}: ${totals[i]}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
                  backgroundColor: Colors.deepOrange,
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
    final ctrls = List.generate(4, (_) => TextEditingController());
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

            // Grid yapısı ile daha düzenli görünüm
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, i) {
                return TextField(
                  controller: ctrls[i],
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: widget.playerNames[i],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < 4; i++) {
                    int s = int.tryParse(ctrls[i].text) ?? 0;
                    int p = pCurrentPenalties[i].fold(0, (a, b) => a + b);
                    pHistory[i].add(s + p);
                    pCurrentPenalties[i].clear();
                  }

                  if (currentRound >= widget.totalRounds) {
                    List<int> t = pHistory
                        .map((h) => h.fold(0, (a, b) => a + b))
                        .toList();
                    currentRound++;
                    _saveGame();
                    Navigator.pop(context);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _showWinnerDialog(t),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "KAYDET",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
        pCurrentPenalties[idx].add(val);
        _scrollToBottom(_controllers[idx]);
        _saveGame();
      });
    }
  }

  void _scrollToBottom(ScrollController c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.hasClients) {
        c.animateTo(
          c.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCustomInput(int idx) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Miktar Gir"),
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
              if (ctrl.text.isNotEmpty && ctrl.text != "-") {
                _addPenalty(idx, int.parse(ctrl.text));
              }
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
            title: const Text("Özel (Eksi Girilebilir)"),
            onTap: () {
              Navigator.pop(context);
              _showCustomInput(idx);
            },
          ),
          const SizedBox(height: 10),
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
    await prefs.setBool('hasSavedGameSS', true); // Tekli oyun için SS suffix
    await prefs.setBool('isTeamGame', false);
    await prefs.setStringList('playerNames', widget.playerNames);
    await prefs.setInt('totalRounds', widget.totalRounds);
    await prefs.setInt('threshold', widget.threshold);
    await prefs.setInt('wrongMovePenalty', widget.wrongMovePenalty);

    // Geçici değişkenler
    await prefs.setInt('currentRound', currentRound);
    // Her oyuncu için listeleri JSON string'e veya basit string'e çevirip saklayalım
    for (int i = 0; i < 4; i++) {
      await prefs.setString('pHistory_$i', pHistory[i].join(','));
      await prefs.setString(
        'pCurrentPenalties_$i',
        pCurrentPenalties[i].join(','),
      );
    }
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasSavedGameSS') == true &&
        prefs.getBool('isTeamGame') == false) {
      List<String> savedNames = prefs.getStringList('playerNames') ?? [];

      // İsim kontrolü
      bool namesMatch = true;
      if (savedNames.length != widget.playerNames.length) {
        namesMatch = false;
      } else {
        for (int i = 0; i < savedNames.length; i++) {
          if (savedNames[i] != widget.playerNames[i]) {
            namesMatch = false;
            break;
          }
        }
      }

      if (namesMatch) {
        setState(() {
          currentRound = prefs.getInt('currentRound') ?? 1;
          for (int i = 0; i < 4; i++) {
            String h = prefs.getString('pHistory_$i') ?? "";
            if (h.isNotEmpty) {
              pHistory[i] = h.split(',').map((e) => int.parse(e)).toList();
            }

            String p = prefs.getString('pCurrentPenalties_$i') ?? "";
            if (p.isNotEmpty) {
              pCurrentPenalties[i] = p
                  .split(',')
                  .map((e) => int.parse(e))
                  .toList();
            }
          }
        });

        // Eğer oyun bitmişse şampiyonu göster
        if (currentRound > widget.totalRounds) {
          List<int> t = pHistory
              .map((h) => h.fold(0, (a, b) => a + b))
              .toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showWinnerDialog(t);
          });
        }
      }
    }
  }

  // _clearSave metodunu sildik, yerine boş bırakıyoruz veya komple siliyoruz.

  // --- GERİ AL (SON ELİ SİL) ---
  void _undoLastRound() {
    if (currentRound <= 1 && (pHistory.isEmpty || pHistory[0].isEmpty)) return;

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
                for (var h in pHistory) {
                  if (h.isNotEmpty) h.removeLast();
                }
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
    List<int> totals = pHistory.map((h) => h.fold(0, (a, b) => a + b)).toList();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor = isDark ? Colors.grey[700]! : Colors.black;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.5,
        title: Text(
          isGameOver
              ? "OYUN BİTTİ"
              : "EL: $currentRound / ${widget.totalRounds}",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Text(
                    widget.playerNames[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: i < 3
                            ? Border(
                                right: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              )
                            : null,
                      ),
                      child: ListView.builder(
                        controller: _controllers[i],
                        itemCount: pCurrentPenalties[i].length,
                        itemBuilder: (context, idx) => Text(
                          "${pCurrentPenalties[i][idx]}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (i) => ElevatedButton(
                  onPressed: isGameOver ? null : () => _showPenaltyMenu(i),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 35),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text("CEZA", style: TextStyle(fontSize: 9)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pHistory.isEmpty ? 0 : pHistory[0].length,
                        itemBuilder: (context, i) => Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.black12,
                              ),
                            ),
                          ),
                          child: Row(
                            children: List.generate(
                              4,
                              (idx) => Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: idx < 3
                                        ? Border(
                                            right: BorderSide(
                                              color: borderColor,
                                              width: 1.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${pHistory[idx][i]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Text(
                        "EL: ${isGameOver ? widget.totalRounds : currentRound} / ${widget.totalRounds}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
      floatingActionButton: _buildFooter(totals),
    );
  }

  Widget _buildFooter(List<int> totals) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.deepOrange[900]!;
    Color buttonColor = isDark ? Colors.deepOrange[900]! : Colors.deepOrange;
    Color containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      // Padding yukarıdaki tablo ile aynı olmalı (horizontal: 20)
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
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: i < 3
                            ? Border(
                                right: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black,
                                ),
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "TOPLAM",
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            "${totals[i]}",
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
                ),
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
                ? () => _showWinnerDialog(totals)
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

  // --- FARK HESAPLAMA ---
  void _showDifferenceDialog() {
    List<int> totals = pHistory.map((h) => h.fold(0, (a, b) => a + b)).toList();
    if (totals.isEmpty) return;

    // En küçük skoru (Lider) bul
    int minScore = totals.reduce((curr, next) => curr < next ? curr : next);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PUAN FARKLARI (Lider'e Göre)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totals.length, (i) {
            int diff = totals[i] - minScore;
            return ListTile(
              title: Text(widget.playerNames[i]),
              trailing: Text(
                diff == 0 ? "LİDER" : "+$diff",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: diff == 0 ? Colors.green : Colors.red,
                  fontSize: 18,
                ),
              ),
            );
          }),
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
            children: [Icon(Icons.casino, size: 80, color: Colors.white)],
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
