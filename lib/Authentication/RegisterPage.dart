import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:nakhwa/Authentication/LoginPage.dart';
import 'package:nakhwa/Widgets/loc.dart';
import 'package:nakhwa/config/config.dart';
import 'package:nakhwa/DialogBox/errorDialog.dart';
import 'package:nakhwa/DialogBox/loadingDialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _selectedCategory;
  String? _selectedUserType;
  File? _profileImage;
  File? _certificatePdf;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserType == "محامي") {
      if (_profileImage == null) {
        showDialog(
          context: context,
          builder: (c) => const ErrorAlertDialog(
            message: "الرجاء اختيار صورة الملف الشخصي",
          ),
        );
        return;
      }
      if (_certificatePdf == null) {
        showDialog(
          context: context,
          builder: (c) =>
              const ErrorAlertDialog(message: "الرجاء اختيار شهادة المحاماة"),
        );
        return;
      }
    }

    if (_agreeToTerms != true) {
      showDialog(
        context: context,
        builder: (c) => const ErrorAlertDialog(
          message: "يجب الموافقة على الشروط والأحكام للمتابعة.",
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const LoadingAlertDialog(message: "جاري إنشاء الحساب..."),
    );

    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String uid = credential.user!.uid;

      String profileImageUrl = '';
      if (_selectedUserType == "محامي" && _profileImage != null) {
        final profileStorageRef = FirebaseStorage.instance.ref().child(
          'profile_images/$uid.jpg',
        );
        await profileStorageRef.putFile(_profileImage!);
        profileImageUrl = await profileStorageRef.getDownloadURL();
      }

      String certificateUrl = '';
      if (_selectedUserType == "محامي" && _certificatePdf != null) {
        final certStorageRef = FirebaseStorage.instance.ref().child(
          'certificates/$uid.pdf',
        );
        await certStorageRef.putFile(_certificatePdf!);
        certificateUrl = await certStorageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': _fullNameController.text.trim(),
        'nationalId': _nationalIdController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'location': _locationController.text.trim(),
        if (_selectedUserType == "مستخدم") 'category': _selectedCategory,
        if (_selectedUserType == "مستخدم")
          'emergencyContact': _emergencyContactController.text.trim(),
        if (_selectedUserType == "مستخدم")
          'emergencyEmail': _emergencyEmailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'Type': _selectedUserType == "محامي" ? "lawyer" : "user",
        if (_selectedUserType == "محامي") 'profileImageUrl': profileImageUrl,
        'status': _selectedUserType == "محامي" ? 'Pending' : 'active',
        if (_selectedUserType == "محامي") 'certificateUrl': certificateUrl,
      });

      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (c) => ErrorAlertDialog(message: error.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Nakhwa.background),
      backgroundColor: Nakhwa.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset("images/logo4.png", height: 60, width: 60),
              const SizedBox(height: 16),
              const Text(
                "إنشاء حساب جديد",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _fullNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "الاسم الكامل*",
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
                        validator: (val) =>
                            val!.isEmpty ? "الرجاء إدخال الاسم الكامل" : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        items: ['مستخدم', 'محامي'].map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedUserType = newValue),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        iconEnabledColor: Colors.white70,
                        decoration: InputDecoration(
                          labelText: "نوع الحساب*",
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
                        dropdownColor: Nakhwa.surface,
                        validator: (val) =>
                            val == null ? "الرجاء اختيار نوع نوع الحساب" : null,
                      ),
                    ),
                    if (_selectedUserType == "محامي")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "صورة الملف الشخصي*",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
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
                                  child: const Text("اختيار صورة"),
                                ),
                                const SizedBox(width: 16),
                                if (_profileImage != null)
                                  const Text(
                                    "تم اختيار الصورة",
                                    style: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (_selectedUserType == "محامي")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "شهادة المحاماة (PDF)*",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );
                                    if (result != null &&
                                        result.files.single.path != null) {
                                      setState(() {
                                        _certificatePdf = File(
                                          result.files.single.path!,
                                        );
                                      });
                                    }
                                  },
                                  child: const Text("اختيار ملف PDF"),
                                ),
                                const SizedBox(width: 16),
                                if (_certificatePdf != null)
                                  const Text(
                                    "تم اختيار الملف",
                                    style: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _nationalIdController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "السجل المدني*",
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
                        validator: (val) => val!.isEmpty
                            ? "الرجاء إدخال رقم السجل المدني"
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _mobileController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "رقم الجوال*",
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
                        validator: (val) =>
                            val!.isEmpty ? "الرجاء إدخال رقم الجوال" : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "البريد الإلكتروني*",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الرجاء إدخال البريد الإلكتروني";
                          }
                          if (!value.contains('@')) {
                            return "البريد الإلكتروني يجب أن يحتوي على @";
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com)$',
                          ).hasMatch(value)) {
                            return "البريد الإلكتروني يجب أن يكون Gmail أو Hotmail";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "كلمة المرور*",
                          labelStyle: const TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الرجاء إدخال كلمة المرور";
                          }
                          if (value.length < 8) {
                            return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return "يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل";
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return "يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل";
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return "يجب أن تحتوي كلمة المرور على رقم واحد على الأقل";
                          }
                          if (!RegExp(
                            r'[!@#$%^&*(),.?":{}|<>]',
                          ).hasMatch(value)) {
                            return "يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: "تأكيد كلمة المرور*",
                          labelStyle: const TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
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
                        validator: (val) => val != _passwordController.text
                            ? "كلمتا المرور غير متطابقتين"
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "الموقع الجغرافي*",
                          labelStyle: const TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const LoadingAlertDialog(
                                  message: "جاري تحديد الموقع...",
                                ),
                              );
                              try {
                                await LocationHelper.setCurrentLocationToController(
                                  _locationController,
                                  context,
                                );
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      ErrorAlertDialog(message: e.toString()),
                                );
                              } finally {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
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
                        validator: (val) => val!.isEmpty
                            ? "الرجاء تحديد الموقع الجغرافي"
                            : null,
                      ),
                    ),
                    if (_selectedUserType == "مستخدم")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: ['طالب', 'سائح', 'رجل أعمال', 'أخرى'].map((
                            String item,
                          ) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => _selectedCategory = newValue),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          iconEnabledColor: Colors.white70,
                          decoration: InputDecoration(
                            labelText: "الفئة (طالب، سائح...)",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Nakhwa.surface.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                          dropdownColor: Nakhwa.surface,
                        ),
                      ),
                    if (_selectedUserType == "مستخدم")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _emergencyContactController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "جهات اتصال الطوارئ",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Nakhwa.surface.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
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
                      ),
                    if (_selectedUserType == "مستخدم")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _emergencyEmailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "بريد الطوارئ",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Nakhwa.surface.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
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
                      ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "موافقة على الشروط والاحكام",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _agreeToTerms,
                      onChanged: (val) => setState(() => _agreeToTerms = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.white,
                      checkColor: Nakhwa.background,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          "تسجيل",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        "تملك حساب؟ سجل دخول",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
