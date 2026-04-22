import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nakhwa/config/config.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Nakhwa.background,
        appBar: AppBar(
          backgroundColor: Nakhwa.background,
          elevation: 0,
          title: const Text(
            'اشعارات الطوارئ',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white24, height: 1),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('SOS')
              .where("userId", isEqualTo: currentUser)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final sosDocs = snapshot.data!.docs;

            if (sosDocs.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد إشعارات حالياً',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sosDocs.length,
              itemBuilder: (context, index) {
                final data = sosDocs[index].data() as Map<String, dynamic>;
                final userName = data['userName'] ?? '';
                final Timestamp? ts = data['timestamp'];
                final location = data['location'];
                String locationText = 'غير معروف';
                if (location is Map &&
                    location['lat'] != null &&
                    location['lng'] != null) {
                  locationText = '(${location['lat']}, ${location['lng']})';
                }
                final time = ts?.toDate();

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الاسم: $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الموقع: $locationText',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الوقت: $time',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
