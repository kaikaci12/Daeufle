import 'package:Daeufle/screens/analyze_results.dart';
import 'package:Daeufle/widgets/question_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Daeufle/constants/colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];

  int _currentIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, String>> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("questions")
          .orderBy("order", descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = "No questions found in Firestore.";
          _isLoading = false;
        });
        print("No questions found in Firestore collection.");
        return;
      }

      _questions = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'selectedOptionId': null,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      _selectedAnswers = List.generate(
        _questions.length,
        (index) => {
          'questionId': _questions[index]['id'] as String,
          'selectedOptionId': '',
        },
      );

      setState(() {
        _isLoading = false;
        _currentIndex = 0;
      });
      print("Successfully loaded ${_questions.length} questions.");
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading questions: $e";
        _isLoading = false;
      });
      print("Error loading questions: $e");
    }
  }

  void _selectOption(String questionId, String optionId) {
    setState(() {
      _questions[_currentIndex]['selectedOptionId'] = optionId;

      final answerEntryIndex = _selectedAnswers.indexWhere(
        (answer) => answer['questionId'] == questionId,
      );
      if (answerEntryIndex != -1) {
        _selectedAnswers[answerEntryIndex]['selectedOptionId'] = optionId;
      } else {
        _selectedAnswers.add({
          'questionId': questionId,
          'selectedOptionId': optionId,
        });
      }
    });
  }

  void _handleNextOrFinish() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        // if (_selectedAnswers.any(
        //   (answer) => answer['selectedOptionId'] == '',
        // )) {
        //   print("შემოვიდაა");
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('გთხოვთ, უპასუხოთ ყველა კითხვას.'),
        //       duration: Duration(seconds: 2),
        //     ),
        //   );
        //   return;
        // }

        print("End of quiz! User's answers: $_selectedAnswers");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AnalyzeResults(selectedAnswers: _selectedAnswers),
          ),
        );
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions.isNotEmpty
        ? _questions[_currentIndex]
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text("კარიერის ქვიზი"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ) // Show error message
              : _questions.isEmpty
              ? const Center(
                  child: Text(
                    "კითხვები არ მოიძებნა.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : QuestionDisplayWidget(
                  question: currentQuestion!,
                  onOptionSelected: _selectOption,
                  onNextQuestion: _handleNextOrFinish,
                  isLastQuestion: _currentIndex == _questions.length - 1,
                  onPreviousQuestion: _currentIndex > 0
                      ? _previousQuestion
                      : null,
                  selectedOptionId:
                      currentQuestion['selectedOptionId'] as String?,
                ),
        ),
      ),
    );
  }
}
