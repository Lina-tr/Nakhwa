import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TODO: Make sure these paths are correct for your project structure
import 'package:nakhwa/config/config.dart';
import 'package:nakhwa/DialogBox/errorDialog.dart';
import 'package:nakhwa/DialogBox/loadingDialog.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const LoadingAlertDialog(message: "جاري إرسال الرابط..."),
    );

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      Navigator.pop(context); // Dismiss loading dialog
      // Show a success message then navigate back
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: Nakhwa.surface,
          title: const Text(
            "تم بنجاح",
            style: TextStyle(color: Colors.greenAccent),
          ),
          content: const Text(
            "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("حسنًا", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      String errorMessage = "حدث خطأ ما. يرجى المحاولة مرة أخرى.";

      showDialog(
        context: context,
        builder: (c) => ErrorAlertDialog(message: errorMessage),
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
              const SizedBox(height: 20),
              Image.asset("images/logo4.png", height: 80, width: 80),
              const SizedBox(height: 24),
              const Text(
                'إعادة تعيين كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'أدخل عنوان بريدك الإلكتروني بالأسفل. سنرسل لك التعليمات لإعادة تعيين كلمة المرور الخاصة بك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال بريدك الإلكتروني';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'الرجاء إدخال بريد إلكتروني صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'إرسال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
