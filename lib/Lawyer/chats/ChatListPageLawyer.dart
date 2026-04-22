import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nakhwa/Lawyer/chats/ChatPageLawyer.dart';
import 'package:nakhwa/config/config.dart';

class ChatListPageLawyer extends StatelessWidget {
  const ChatListPageLawyer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(
        backgroundColor: Nakhwa.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('الدردشات', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').snapshots(),
          builder: (context, chatSnapshot) {
            if (!chatSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final chatDocs = chatSnapshot.data!.docs;
            final userIds = <String>{};

            for (var doc in chatDocs) {
              final parts = doc.id.split('-');
              if (parts.contains(currentUser?.uid)) {
                final otherId = parts[0] == currentUser?.uid
                    ? parts[1]
                    : parts[0];
                userIds.add(otherId);
              }
            }

            if (userIds.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد دردشات حتى الآن',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: userIds.toList())
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final users = userSnapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final uid = users[index].id;
                    final fullName = user['fullName'] ?? 'مستخدم';
                    final profileImageUrl = user['profileImageUrl'] ?? '';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPageLawyer(
                              lawyerId: uid,
                              lawyerName: fullName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null,
                              backgroundColor: Colors.grey[400],
                              radius: 24,
                              child: profileImageUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
