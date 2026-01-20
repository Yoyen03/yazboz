import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ScoreboardScreen extends StatefulWidget {
  final bool isTeamGame;
  final String team1Name;
  final String team2Name;
  final int totalRounds;
  final int threshold;
  final int wrongMovePenalty;

  const ScoreboardScreen({
    super.key,
    required this.isTeamGame,
    required this.team1Name,
    required this.team2Name,
    required this.totalRounds,
    required this.threshold,
    required this.wrongMovePenalty,
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "${widget.team1Name} PUANI",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: t2,
              keyboardType: TextInputType.number,
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
                    currentRound++; // isGameOver'ı tetiklemek için
                    Navigator.pop(context);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _showWinnerDialog(f1, f2),
                    );
                  } else {
                    currentRound++;
                    Navigator.pop(context);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
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

  // --- CEZA VE ÖZEL PUAN SİSTEMİ (ÇALIŞAN HALİ) ---
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
  Widget build(BuildContext context) {
    int t1 = team1History.fold(0, (a, b) => a + b);
    int t2 = team2History.fold(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGameOver
              ? "OYUN BİTTİ"
              : "EL: $currentRound / ${widget.totalRounds}",
        ),
        centerTitle: true,
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.team2Name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
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
                  Container(width: 1.5, color: Colors.black),
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
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: team1History.length,
                        itemBuilder: (context, i) => Row(
                          children: [
                            Expanded(
                              child: Center(child: Text("${team1History[i]}")),
                            ),
                            Container(
                              width: 1.5,
                              height: 45,
                              color: Colors.black,
                            ),
                            Expanded(
                              child: Center(child: Text("${team2History[i]}")),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      color: Colors.black12,
                      child: Text(
                        "EL: ${isGameOver ? widget.totalRounds : currentRound} / ${widget.totalRounds}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: _showTotalScores
                      ? Text(
                          "$t1",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 18,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
              Row(
                children: [
                  _utilBtn("ZAR AT", _rollDice, Icons.casino),
                  const SizedBox(width: 10),
                  _utilBtn(
                    _showTotalScores ? "GİZLE" : "SKOR",
                    () => setState(() => _showTotalScores = !_showTotalScores),
                    Icons.visibility,
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: _showTotalScores
                      ? Text(
                          "$t2",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 18,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: isGameOver
                ? () => _showWinnerDialog(t1, t2)
                : _showScoreEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: isGameOver
                  ? Colors.orange[800]
                  : Colors.deepPurple,
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

  Widget _utilBtn(String t, VoidCallback p, IconData i) => OutlinedButton.icon(
    onPressed: p,
    icon: Icon(i, size: 14),
    label: Text(t, style: const TextStyle(fontSize: 10)),
  );
  void _rollDice() {
    /* Zar mantığı */
  }
}
