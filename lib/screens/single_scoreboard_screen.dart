import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SingleScoreboardScreen extends StatefulWidget {
  final List<String> playerNames;
  final int totalRounds;
  final int threshold;
  final int wrongMovePenalty;

  const SingleScoreboardScreen({
    super.key,
    required this.playerNames,
    required this.totalRounds,
    required this.threshold,
    required this.wrongMovePenalty,
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

  // ZAR ATMA FONKSİYONU
  void _rollDice() {
    int d1 = Random().nextInt(6) + 1;
    int d2 = Random().nextInt(6) + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🎲 ZAR SONUCU: $d1 - $d2",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
      ),
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
                color: Colors.deepPurple,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              4,
              (i) => Text("${widget.playerNames[i]}: ${totals[i]}"),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("SONUÇLARI İNCELE"),
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
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: ctrls[i],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "${widget.playerNames[i]} PUANI",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < 4; i++) {
                    int s = int.tryParse(ctrls[i].text) ?? 0;
                    pHistory[i].add(
                      s + pCurrentPenalties[i].fold(0, (a, b) => a + b),
                    );
                    pCurrentPenalties[i].clear();
                  }
                  if (currentRound >= widget.totalRounds) {
                    List<int> t = pHistory
                        .map((h) => h.fold(0, (a, b) => a + b))
                        .toList();
                    currentRound++;
                    Navigator.pop(context);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _showWinnerDialog(t),
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
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // CEZA SİSTEMİ
  void _addPenalty(int idx, int val) {
    if (!isGameOver) {
      setState(() {
        pCurrentPenalties[idx].add(val);
        _scrollToBottom(_controllers[idx]);
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
            title: const Text("Özel (Eksi Girilebilir)"),
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
    List<int> totals = pHistory.map((h) => h.fold(0, (a, b) => a + b)).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          isGameOver
              ? "OYUN BİTTİ"
              : "EL: $currentRound / ${widget.totalRounds}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: i < 3
                            ? const Border(
                                right: BorderSide(
                                  color: Colors.black,
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
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: pHistory.isEmpty ? 0 : pHistory[0].length,
                        itemBuilder: (context, i) => Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: Row(
                            children: List.generate(
                              4,
                              (idx) => Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: idx < 3
                                        ? const Border(
                                            right: BorderSide(
                                              color: Colors.black,
                                              width: 1.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${pHistory[idx][i]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
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
                    // DÜZELTİLEN GRİ ŞERİT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ), // Yükseklik artırıldı
                      color: Colors.black12,
                      child: Text(
                        "EL: ${isGameOver ? widget.totalRounds : currentRound} / ${widget.totalRounds}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 160), // Butonlar için boşluk
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFooter(totals),
    );
  }

  Widget _buildFooter(List<int> totals) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showTotalScores)
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      "${totals[i]}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _utilBtn("ZAR AT", _rollDice, Icons.casino),
              _utilBtn(
                _showTotalScores ? "GİZLE" : "SKOR",
                () => setState(() => _showTotalScores = !_showTotalScores),
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
}
