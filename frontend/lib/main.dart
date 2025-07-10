import 'package:Daeufle/constants/colors.dart';
import 'package:Daeufle/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "screens/welcome.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: MaterialColor(0xFF416FDF, <int, Color>{
          50: Color(0xFFE3EAF7),
          100: Color(0xFFB9CBEF),
          200: Color(0xFF8BABE6),
          300: Color(0xFF5D8BDD),
          400: Color(0xFF396FD6),
          500: Color(0xFF416FDF),
          600: Color(0xFF3863C9),
          700: Color(0xFF2F56B3),
          800: Color(0xFF26499D),
          900: Color(0xFF1D3C87),
        }),
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}
