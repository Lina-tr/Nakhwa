import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nakhwa/config/config.dart';

class AllBookingPageLawyer extends StatelessWidget {
  const AllBookingPageLawyer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLawyerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(
        backgroundColor: Nakhwa.background,
        elevation: 0,
        title: const Text(
          'جميع المواعيد',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('lawyerId', isEqualTo: currentLawyerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد مواعيد حالياً',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final bookingId = bookings[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الاسم: ${data['lawyerName'] ?? ''}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'التاريخ: ${data['date']} - الوقت: ${data['time']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الحالة: ${data['status']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data['status'] == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(bookingId)
                                  .update({'status': 'rejected'});
                            },
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: const Text(
                              'رفض',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(bookingId)
                                  .update({'status': 'accepted'});
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'قبول',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
