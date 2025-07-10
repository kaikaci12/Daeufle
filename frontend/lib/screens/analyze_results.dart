import 'package:Daeufle/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnalyzeResults extends StatefulWidget {
  final List<Map<String, String>> selectedAnswers;
  AnalyzeResults({required this.selectedAnswers});

  @override
  State<AnalyzeResults> createState() => _AnalyzeResultsState();
}

class _AnalyzeResultsState extends State<AnalyzeResults>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Analyzing Results...',
                style: TextStyle(fontSize: 30, color: AppColors.purpleAccent),
              ),
              SizedBox(height: 40),
              Lottie.asset(
                "assets/analyze-animation.json",
                controller: _controller,
                onLoaded: (composition) {
                  _controller..repeat();
                },
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
