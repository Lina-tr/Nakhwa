import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../config/config.dart';

class LawyerEditProfilePage extends StatefulWidget {
  const LawyerEditProfilePage({super.key});

  @override
  State<LawyerEditProfilePage> createState() => _LawyerEditProfilePageState();
}

class _LawyerEditProfilePageState extends State<LawyerEditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _saving = false;
  File? _profileImage;
  File? _certificatePdf;
  String? _profileImageUrl;
  String? _certificateUrl;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _savingData() async {
    setState(() => _saving = true);

    if (_profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/$uid.jpg',
      );
      await ref.putFile(_profileImage!);
      _profileImageUrl = await ref.getDownloadURL();
    }

    if (_certificatePdf != null) {
      final ref = FirebaseStorage.instance.ref().child('certificates/$uid.pdf');
      await ref.putFile(_certificatePdf!);
      _certificateUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fullName': _nameController.text.trim(),
      'mobileNumber': _phoneController.text.trim(),
      if (_profileImageUrl != null) 'profileImageUrl': _profileImageUrl,
      if (_certificateUrl != null) 'certificateUrl': _certificateUrl,
    });

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nakhwa.background,
      appBar: AppBar(
        backgroundColor: Nakhwa.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            if (_nameController.text.isEmpty) {
              _nameController.text = data['fullName'] ?? '';
            }
            if (_phoneController.text.isEmpty) {
              _phoneController.text = data['mobileNumber'] ?? '';
            }
            _profileImageUrl ??= data['profileImageUrl'];
            _certificateUrl ??= data['certificateUrl'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
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
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Nakhwa.surface.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Nakhwa.surface.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: const Text('اختيار صورة الملف الشخصي'),
                ),
                const SizedBox(height: 8),
                if (_profileImage != null)
                  Image.file(_profileImage!, height: 100)
                else if (_profileImageUrl != null)
                  Image.network(_profileImageUrl!, height: 100),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      setState(() {
                        _certificatePdf = File(result.files.single.path!);
                      });
                    }
                  },
                  child: const Text('اختيار شهادة المحاماة (PDF)'),
                ),
                const SizedBox(height: 8),
                if (_certificatePdf != null)
                  const Text(
                    '✔ تم اختيار الشهادة',
                    style: TextStyle(color: Colors.white),
                  )
                else if (_certificateUrl != null)
                  Text(
                    '📄 الشهادة محفوظة بالفعل',
                    style: TextStyle(color: Colors.white),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _saving == true ? null : _savingData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      _saving ? 'جاري الحفظ...' : 'حفظ التعديلات',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
