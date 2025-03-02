import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  int selectedSession = 1;
  int selectedDifficulty = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: selectedSession,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Session 1: Crude Drugs')),
                DropdownMenuItem(value: 2, child: Text('Session 2: Proprietary Drugs')),
                DropdownMenuItem(value: 3, child: Text('Session 3: Macroscopy')),
                DropdownMenuItem(value: 4, child: Text('Session 4: Microscopy 1')),
                DropdownMenuItem(value: 5, child: Text('Session 5: Microscopy 2')),
                DropdownMenuItem(value: 6, child: Text('Session 6: Diagnostic Characters')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSession = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: selectedDifficulty,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Easy (60s, MCQ)')),
                DropdownMenuItem(value: 2, child: Text('Medium (30s, MCQ)')),
                DropdownMenuItem(value: 3, child: Text('Hard (15s, Fill-in)')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      session: selectedSession,
                      difficulty: selectedDifficulty,
                    ),
                  ),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}