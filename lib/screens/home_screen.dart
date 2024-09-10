import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/screens/chat_history_screen.dart';
import 'package:gemini_chat_bot/screens/chat_screen.dart';
import 'package:gemini_chat_bot/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
// lisy of screeens
  final List<Widget> _screens = [
    const ChatHistoryScreen(),
    const ChatScreen(),
    const ProfileScreen()
  ];

  //index of the current screen
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        elevation: 0,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
          _pageController.jumpToPage(value);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Chat History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
