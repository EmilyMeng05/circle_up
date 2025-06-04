// import 'package:circle_up/views/home_page.dart';
// import 'package:circle_up/views/upload_photos.dart';
// import 'package:circle_up/views/personal_alarm_page.dart';
// import 'package:flutter/material.dart';

// class BottomNavigationBarExampleApp extends StatelessWidget {
//   const BottomNavigationBarExampleApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(home: BottomNavigationBarExample());
//   }
// }

// class BottomNavigationBarExample extends StatefulWidget {
//   const BottomNavigationBarExample({super.key});

//   @override
//   State<BottomNavigationBarExample> createState() => _BottomNavigationBarExampleState();
// }

// class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text('Index 0: Home', style: optionStyle),
//     Text('Index 1: Business', style: optionStyle),
//     Text('Index 2: School', style: optionStyle),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: (() {
//         switch (_selectedIndex) {
//           case 0:
//             return const PersonalAlarmPage();
//           case 1:
//             return UploadPhotos();
//           case 2:
//             return HomePage();
//         }
//       })(),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Personal'),
//           BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Photos'),
//           BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
//         ],
//         currentIndex: _selectedIndex,
//         backgroundColor: Colors.grey[300],
//         selectedItemColor: Colors.amber[800],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }