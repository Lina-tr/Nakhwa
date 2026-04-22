import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nakhwa/Users/Home/Chats/ChatDetailPage.dart';
import 'package:nakhwa/config/config.dart';

class LawyerDetailsPage extends StatefulWidget {
  final String lawyerId;
  const LawyerDetailsPage({super.key, required this.lawyerId});

  @override
  State<LawyerDetailsPage> createState() => _LawyerDetailsPageState();
}

class _LawyerDetailsPageState extends State<LawyerDetailsPage> {
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedDay; // Add this to store the day name in Arabic

  String _getChatId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? '$user1-$user2' : '$user2-$user1';
  }

  // Add this method to convert date to Arabic day name
  String _getArabicDayName(DateTime date) {
    final days = {
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
      DateTime.monday: 'الاثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
    };
    return days[date.weekday] ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Nakhwa.greenColor,
              onPrimary: Colors.white,
              surface: Nakhwa.background,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Nakhwa.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.day}/${picked.month}/${picked.year}";
        _selectedDay = _getArabicDayName(picked);
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  // Replace the time selection Wrap widget with this:
  Widget _buildTimeSelection(Map<String, dynamic> data) {
    final weeklyAvailability =
        data['weeklyAvailability'] as Map<String, dynamic>?;
    if (weeklyAvailability == null || _selectedDay == null) {
      return const Center(
        child: Text(
          'يرجى اختيار التاريخ أولاً',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final availableHours = List<String>.from(
      weeklyAvailability[_selectedDay] ?? [],
    );
    if (availableHours.isEmpty) {
      return const Center(
        child: Text(
          'لا تتوفر مواعيد في هذا اليوم',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: availableHours.map((time) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedTime == time ? Colors.green : Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(time, style: const TextStyle(color: Colors.white)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(backgroundColor: Nakhwa.background, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.lawyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('محامي'),
                              const SizedBox(height: 4),
                              Text(
                                data['description'] ?? '',
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text("متاح", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(
                            data['profileImageUrl'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['mobileNumber'] ?? '',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['email'] ?? '',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['location'] ?? '',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "اختر الخدمة",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                "استشارة 30 دقيقة",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "${data['consultationPrice'] ?? 'غير محدد'} \$",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "التاريخ والوقت",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              _selectedDate ?? 'اختر التاريخ',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTimeSelection(data),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_selectedDate == null ||
                                _selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى اختيار التاريخ والوقت'),
                                ),
                              );
                              return;
                            }
                            await FirebaseFirestore.instance
                                .collection('bookings')
                                .add({
                                  'userId': currentUser?.uid,
                                  'lawyerId': widget.lawyerId,
                                  'lawyerName': data['fullName'],
                                  'lawyerEmail': data['email'],
                                  'status': 'pending',
                                  'timestamp': Timestamp.now(),
                                  'date': _selectedDate,
                                  'time': _selectedTime,
                                  'consultationPrice':
                                      data['consultationPrice'] ?? 'غير محدد',
                                });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إرسال طلب الموعد'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("إنشاء موعد"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  chatId: _getChatId(
                                    currentUser!.uid,
                                    widget.lawyerId,
                                  ),
                                  lawyerId: widget.lawyerId,
                                  lawyerName: data['fullName'],
                                ),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("محادثة مع المحامي"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
