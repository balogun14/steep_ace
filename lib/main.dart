import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steep_ace/screens/home_screen.dart';
import 'dart:convert';
import 'package:steep_ace/helpers/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await populateQuestions();
  runApp(const SteepAceApp());
}

class SteepAceApp extends StatelessWidget {
  const SteepAceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steep Ace',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const FirstLaunchScreen(),
    );
  }
}

class FirstLaunchScreen extends StatefulWidget {
  const FirstLaunchScreen({super.key});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') == null) {
      _showNameDialog();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Welcome to Steep Ace!', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', _nameController.text);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}




Future<void> populateQuestions() async {
  final dbHelper = DatabaseHelper.instance;

  // Session 1 Example (Crude Drugs)
  await dbHelper.insertQuestion({
    'session': 1,
    'question': 'What is the botanical source of turmeric?',
    'answer': 'Curcuma longa',
    'options': jsonEncode(['Curcuma longa', 'Zingiber officinale', 'Piper nigrum', 'Capsicum annuum']),
    'imagePath': 'assets/images/turmeric.jpeg', // Add images to assets folder
    'difficulty': 1, // Easy
  });

  // Add more questions for all sessions (21 for Session 1, 20 for Session 2, etc.)
  // Example for Session 4 (Microscopy)
  await dbHelper.insertQuestion({
    'session': 4,
    'question': 'Identify this X10 microscopy image.',
    'answer': 'Wheat Starch',
    'options': jsonEncode(['Wheat Starch', 'Soluble Starch', 'Talium Triangulare', 'None']),
    'imagePath': 'assets/images/wheat_starch_x10.jpeg',
    'difficulty': 1,
  });

  // Repeat for all sessions, difficulties, and question types
}