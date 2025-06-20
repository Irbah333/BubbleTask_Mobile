import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tabs/home_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/priority_tab.dart';
import 'tabs/profile_tab.dart';
import 'add_task_screen.dart';
import 'auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  List<Widget> get _tabs => [
    HomeTab(userId: _userId ?? 0),
    CalendarTab(userId: _userId ?? 0),
    PriorityTab(userId: _userId ?? 0),
    ProfileTab(userId: _userId ?? 0),
  ];

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return LoginScreen();
    }

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE3F2FD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Color(0xFF5C6BC0),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen(userId: _userId!)),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Color(0xFF5C6BC0),
        child: Icon(Icons.add, color: Colors.white),
      ),
      // Move FAB closer to the left (towards Calendar and Priority tabs)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

