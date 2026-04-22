import 'package:flutter/material.dart';
import 'package:nakhwa/Users/Home/Services/public/ContactPolice.dart';
import 'package:nakhwa/Users/Home/Services/public/SaveMapPages.dart';
import 'package:nakhwa/Users/Home/Services/public/weather.dart';
import 'package:nakhwa/Users/Home/Services/public/Notifications.dart';
import 'package:nakhwa/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String selectedTab = 'الصحية';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  // List of public services with their properties
  final List<Map<String, dynamic>> publicServices = [
    {
      'icon': Icons.cloud,
      'title': 'الطقس',
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeatherServicePage()),
        );
      },
    },
    {
      'icon': Icons.warning,
      'title': 'اشعارات الطوارئ',
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      },
    },
    {
      'icon': Icons.contact_phone,
      'title': 'التواصل مع الجهات',
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContactAuthoritiesPage()),
        );
      },
    },

    {
      'icon': Icons.map,
      'title': 'خرائط الامان',
      'onTap': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SafeMapPage()),
        );
      },
    },
  ];

  // List of health form fields
  final List<String> healthFields = [
    'الاسم كامل :',
    'تاريخ الميلاد :',
    'رقم الهوية :',
    'الجنس :',
    'رقم الهاتف :',
    'عنوان السكن :',
    'الأمراض المزمنة :',
    'الحساسية :',
    'الزوجه الحالية :',
    'جهة الاتصال في حالات الطوارئ :',
    'حالة صحية خاصة :',
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in healthFields) field: TextEditingController(),
    };
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null && data['healthData'] != null) {
      final hd = Map<String, dynamic>.from(data['healthData']);
      for (final field in healthFields) {
        _controllers[field]?.text = hd[field] ?? '';
      }
    }
  }

  Future<void> _saveHealthData() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final hd = {for (final f in healthFields) f: _controllers[f]!.text.trim()};
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'healthData': hd,
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ المعلومات الصحية')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Nakhwa.background,
        appBar: AppBar(
          backgroundColor: Nakhwa.background,
          elevation: 0,
          title: const Text(
            'جميع الخدمات الامنة في مكان واحد!',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white24, height: 1),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['الصحية', 'العامة'].map((tab) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selectedTab == tab
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: selectedTab == 'العامة'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: publicServices.map((service) {
                          return _buildServiceItem(
                            icon: service['icon'],
                            title: service['title'],
                            onTap: () => service['onTap'](context),
                          );
                        }).toList(),
                      )
                    : selectedTab == 'الصحية'
                    ? Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "معلومات",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...healthFields.map((field) {
                              return _buildInfoField(field, editable: true);
                            }).toList(),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _saveHealthData();
                                },
                                child: const Text('حفظ'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'قريبًا...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Text("فتح", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, {bool editable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controllers[label],
              readOnly: !editable,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (v) =>
                  editable && (v == null || v.isEmpty) ? 'مطلوب' : null,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
