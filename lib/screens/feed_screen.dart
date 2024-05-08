import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytube/widgets/profile_widget.dart';
import 'package:mytube/widgets/reel_add_widget.dart';
import 'package:mytube/widgets/reel_widegt.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.user});
  final User user;
  @override
  State<FeedScreen> createState() {
    return _FeedScreenState();
  }
}

class _FeedScreenState extends State<FeedScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const ReelWidget(),
      ReelAddWidget(
        userUid: widget.user.uid,
      ),
      ProfileWidget(
        userUid: widget.user.uid,
      ),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 64, 255, 89),
        selectedFontSize: 15,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: screens[currentIndex],
    );
  }
}
