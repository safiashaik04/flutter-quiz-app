import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class ScoreScreen extends StatefulWidget {
  final int score;
  final int total;

  ScoreScreen({required this.score, required this.total});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt("high_score") ?? 0;

    if (widget.score > highScore) {
      await prefs.setInt("high_score", widget.score);
      highScore = widget.score;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Score")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Quiz Finished!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Your Score: ${widget.score}/${widget.total}",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("High Score: $highScore", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
