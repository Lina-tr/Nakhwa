import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/config.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<String> _selectedServices = [];
  final List<String> _allServices = [
    'قضايا جنائية',
    'قضايا مدنية',
    'أحوال شخصية',
    'شركات وعقود',
    'استشارات قانونية',
    'تحصيل ديون',
    'قضايا عمالية',
  ];
  final Map<String, List<String>> _weeklyAvailability = {
    'السبت': [],
    'الأحد': [],
    'الاثنين': [],
    'الثلاثاء': [],
    'الأربعاء': [],
    'الخميس': [],
    'الجمعة': [],
  };
  final List<String> _hours = List.generate(24, (i) => '${i}:00');
  bool _saving = false;

  Future<void> _saveInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    setState(() => _saving = true);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'description': _descriptionController.text.trim(),
      'services': _selectedServices,
      'weeklyAvailability': _weeklyAvailability,
      'consultationPrice': _priceController.text.trim(),
    });

    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح')));
  }

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      _descriptionController.text = data['description'] ?? '';
      _priceController.text = data['consultationPrice'] ?? '';
      final services = data['services'] as List<dynamic>?;
      if (services != null) {
        _selectedServices.addAll(services.cast<String>());
      }
      final availability = data['weeklyAvailability'] as Map<String, dynamic>?;
      if (availability != null) {
        availability.forEach((day, hours) {
          _weeklyAvailability[day] = List<String>.from(hours);
        });
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('المستخدم غير مسجل')));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Nakhwa.background),
      backgroundColor: Nakhwa.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "تعديل البيانات الشخصية",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'الوصف المهني',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Nakhwa.surface.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                labelText: 'نبذة عنك',
                labelStyle: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'سعر الاستشارة',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Nakhwa.surface.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                labelText: 'السعر',
                labelStyle: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الخدمات القانونية التي تقدمها',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allServices.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدد الأوقات المتاحة حسب اليوم',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._weeklyAvailability.keys.map((day) {
              return ExpansionTile(
                collapsedIconColor: Colors.white70,
                iconColor: Colors.white,
                title: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: _hours.map((hour) {
                  final selected = _weeklyAvailability[day]!.contains(hour);
                  return CheckboxListTile(
                    title: Text(
                      hour,
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: selected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _weeklyAvailability[day]!.add(hour);
                        } else {
                          _weeklyAvailability[day]!.remove(hour);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.white,
                    checkColor: Nakhwa.background,
                  );
                }).toList(),
              );
            }).toList(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _saving == true ? null : _saveInfo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text(
                      'حفظ المعلومات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
