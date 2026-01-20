import 'package:flutter/material.dart';
import 'player_entry_screen.dart';
import 'single_player_entry_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/okey_arka_plan.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF1B5E20)),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'YAZ-BOZ',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber[700],
                      letterSpacing: 8,
                      shadows: const [
                        Shadow(
                          blurRadius: 15.0,
                          color: Colors.black,
                          offset: Offset(4.0, 4.0),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: ElevatedButton(
                      onPressed: () => _showModeSelection(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
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
                        'GİRİŞ YAP',
                        style: TextStyle(
                          fontSize: 22,
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

  void _showModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "OYUN MODU SEÇ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            _modeButton(
              context,
              "EŞLİ OYUN",
              Icons.groups,
              Colors.blue[800]!,
              const PlayerEntryScreen(),
            ),
            const SizedBox(height: 12),
            _modeButton(
              context,
              "TEKLİ OYUN",
              Icons.person,
              Colors.orange[800]!,
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
