import 'package:flutter/material.dart';
import 'package:nakhwa/Users/Home/AI/chatBotAI.dart';
import 'package:nakhwa/Users/Home/HomePage.dart';
import 'package:nakhwa/Users/Home/Lawyers/AllLawyers.dart';
import 'package:nakhwa/Users/Home/Profile/SettingsPage.dart';
import 'package:nakhwa/Users/Home/Services/ServicesHomePage.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    NakhwaAlertPage(),
    LegalConsultationPage(),
    ServicesPage(),
    DisasterChatbotPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff264E3D),

      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xffB3C8A1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff763516),
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),

          BottomNavigationBarItem(
            icon: Icon(Icons.balance_outlined),
            label: 'قانونية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service_outlined),
            label: 'خدماتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'الذكاء',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}
