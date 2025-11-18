import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int category = 9;
  String difficulty = "easy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Start Quiz")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,            // keeps column centered
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CATEGORY TITLE
              Text(
                "Select Category",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // CATEGORY DROPDOWN CENTERED
              Center(
                child: DropdownButton<int>(
                  value: category,
                  alignment: Alignment.center,
                  items: [
                    DropdownMenuItem(
                        value: 9, child: Text("General Knowledge")),
                    DropdownMenuItem(value: 21, child: Text("Sports")),
                    DropdownMenuItem(value: 23, child: Text("History")),
                  ],
                  onChanged: (v) => setState(() => category = v!),
                ),
              ),

              SizedBox(height: 25),

              // DIFFICULTY TITLE
              Text(
                "Select Difficulty",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // DIFFICULTY DROPDOWN CENTERED
              Center(
                child: DropdownButton<String>(
                  value: difficulty,
                  alignment: Alignment.center,
                  items: [
                    DropdownMenuItem(value: "easy", child: Text("Easy")),
                    DropdownMenuItem(value: "medium", child: Text("Medium")),
                    DropdownMenuItem(value: "hard", child: Text("Hard")),
                  ],
                  onChanged: (v) => setState(() => difficulty = v!),
                ),
              ),

              SizedBox(height: 40),

              // START QUIZ BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        category: category,
                        difficulty: difficulty,
                      ),
                    ),
                  );
                },
                child: Text("Start Quiz"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
