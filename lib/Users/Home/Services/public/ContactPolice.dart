import 'package:flutter/material.dart';
import 'package:nakhwa/config/config.dart';

class ContactAuthoritiesPage extends StatelessWidget {
  const ContactAuthoritiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(
        backgroundColor: Nakhwa.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'التواصل مع الجهات',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "اختر الجهة للتواصل:",
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // الشرطة
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.local_police, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'الشرطة',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text("999", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // الإسعاف
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.medical_services, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'الإسعاف',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text("997", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // الدفاع المدني
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.fire_extinguisher, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'الدفاع المدني',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text("998", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // المرور
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.traffic, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'المرور',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text("993", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // الإبلاغ
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.report_problem, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'الإبلاغ عن حالة طارئة',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Text("911", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
