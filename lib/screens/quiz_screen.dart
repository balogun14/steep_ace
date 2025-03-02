import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steep_ace/helpers/database_helper.dart';
import 'package:steep_ace/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  final int session;
  final int difficulty;

  const QuizScreen({super.key, required this.session, required this.difficulty});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestion = 0;
  int score = 0;
  late int timerSeconds;
  Timer? _timer;
  String userAnswer = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    timerSeconds = widget.difficulty == 1 ? 60 : widget.difficulty == 2 ? 30 : 15;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final dbHelper = DatabaseHelper.instance;
    questions = await dbHelper.getQuestions(widget.session, widget.difficulty);
    setState(() {
      isLoading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          _nextQuestion();
        }
      });
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (userAnswer == questions[currentQuestion]['answer']) {
      score++;
    }
    setState(() {
      currentQuestion++;
      userAnswer = '';
      if (currentQuestion < questions.length) {
        timerSeconds = widget.difficulty == 1 ? 60 : widget.difficulty == 2 ? 30 : 15;
        _startTimer();
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Unknown';
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertScore(userName, widget.session, widget.difficulty, score);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen(score: score)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final question = questions[currentQuestion];
    final options = jsonDecode(question['options']) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestion + 1}/${questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time Left: $timerSeconds s', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(question['question'], style: const TextStyle(fontSize: 20)),
            if (question['imagePath'] != null) ...[
              const SizedBox(height: 20),
              Image.asset(question['imagePath'], height: 100),
            ],
            const SizedBox(height: 20),
            if (widget.difficulty < 3) ...[
              ...options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          userAnswer = option;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userAnswer == option ? Colors.grey : Colors.white,
                      ),
                      child: Text(option),
                    ),
                  )),
            ] else
              TextField(
                onChanged: (value) => userAnswer = value,
                decoration: const InputDecoration(hintText: 'Type your answer'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: userAnswer.isNotEmpty ? _nextQuestion : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}