import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mytube/screens/feed_screen.dart';
import 'package:mytube/screens/login_screen.dart';
import 'package:mytube/utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mytube',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          background: const Color.fromARGB(255, 241, 160, 187),
          primaryContainer: const Color.fromARGB(255, 231, 75, 127),
          onSecondary: Colors.red,
        ),
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? FeedScreen(
              user: FirebaseAuth.instance.currentUser!,
            )
          : const LoginScreen(),
    );
  }
}
