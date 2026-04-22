import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nakhwa/Users/Home/Lawyers/lawyerDetailes.dart';
import 'package:nakhwa/config/config.dart';

class LegalConsultationPage extends StatefulWidget {
  const LegalConsultationPage({super.key});

  @override
  State<LegalConsultationPage> createState() => _LegalConsultationPageState();
}

class _LegalConsultationPageState extends State<LegalConsultationPage> {
  final List<String> _allServices = [
    'الكل',
    'قضايا جنائية',
    'قضايا مدنية',
    'أحوال شخصية',
    'شركات وعقود',
    'استشارات قانونية',
    'تحصيل ديون',
    'قضايا عمالية',
  ];
  String selectedCategory = 'الكل';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nakhwa.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر الفئة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _allServices.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => selectedCategory = cat),
                        selectedColor: Nakhwa.greenColor,
                        backgroundColor: isSelected == true
                            ? Nakhwa.greenColor
                            : Colors.black.withOpacity(
                                0.2,
                              ), // light black for unselected
                        labelStyle: TextStyle(color: Colors.white),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('Type', isEqualTo: 'lawyer')
                      .where('status', isEqualTo: 'accepted')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || _currentPosition == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lawyers = snapshot.data!.docs;
                    final filtered = lawyers.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final services = List<String>.from(
                        data['services'] ?? [],
                      );
                      if (selectedCategory == 'الكل') {
                        return true; // Show all lawyers when 'All' is selected
                      }
                      return services.contains(selectedCategory);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final lawyerDoc = filtered[index];
                              final lawyer =
                                  lawyerDoc.data() as Map<String, dynamic>;
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LawyerDetailsPage(
                                        lawyerId: lawyerDoc.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundImage: NetworkImage(
                                          lawyer['profileImageUrl'] ?? '',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lawyer['fullName'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              lawyer['description'] ??
                                                  'بدون وصف',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'السعر: ${lawyer['consultationPrice'] ?? 'غير محدد'} \SAR',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_sharp),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'محامون بالقرب منك',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 170,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: filtered.take(10).map((doc) {
                              final lawyer = doc.data() as Map<String, dynamic>;
                              final location = lawyer['location'] ?? '';
                              double? distance;
                              try {
                                final lat = double.parse(
                                  location.split(',')[0].split(':')[1].trim(),
                                );
                                final lng = double.parse(
                                  location.split(',')[1].split(':')[1].trim(),
                                );
                                distance =
                                    Geolocator.distanceBetween(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      lat,
                                      lng,
                                    ) /
                                    1000;
                              } catch (_) {}

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LawyerDetailsPage(lawyerId: doc.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          lawyer['profileImageUrl'] ?? '',
                                        ),
                                        radius: 26,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        lawyer['fullName'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (distance != null)
                                        Text(
                                          '${distance.toStringAsFixed(1)} كم',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${lawyer['consultationPrice'] ?? 'غير محدد'} \SAR',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
