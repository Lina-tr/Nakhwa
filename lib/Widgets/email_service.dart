import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static const String _username = 'sanad002321@gmail.com';
  static const String _password = 'wtolyhhyxtamweii';

  static Future<void> sendEmail({
    required List<String> recipients,
    required String subject,
    required String body,
    String fromName = 'Nakhwa',
  }) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, fromName)
      ..recipients.addAll(recipients)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
      print('✅ Email sent to ${recipients.join(', ')}');
    } catch (e) {
      print('❌ Failed to send email: $e');
    }
  }
}
