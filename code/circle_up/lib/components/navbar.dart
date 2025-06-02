import 'package:flutter/material.dart';

class ScaffoldWithNav extends StatefulWidget {
  final int initialIndex;

  const ScaffoldWithNav({super.key, this.initialIndex = 0});

  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  late int _currentIndex;

  final List<String> _routes = [
    '/alarm',
    '/upload',
    '/group',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the corresponding route
    Navigator.pushNamedAndRemoveUntil(
      context,
      _routes[index],
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarm'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Photo'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
        ],
      ),
    );
  }
}
