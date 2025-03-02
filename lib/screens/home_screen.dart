import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steep_ace/helpers/database_helper.dart';
import 'quiz_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steep Ace'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizSelectionScreen()),
                );
              },
              child: const Text('Start Quiz'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userName = prefs.getString('userName') ?? 'Unknown';
                final dbHelper = DatabaseHelper.instance;
                final scores = await dbHelper.getScores(userName);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Your Scores'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: scores.map((score) => ListTile(
                          title: Text('Session ${score['session']} - Difficulty ${score['difficulty']}'),
                          subtitle: Text('Score: ${score['score']}/30 - ${score['date']}'),
                        )).toList(),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('View Scores'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}