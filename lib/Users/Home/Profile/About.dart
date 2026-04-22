import 'package:flutter/material.dart';
import 'package:nakhwa/config/config.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Nakhwa.background,
        appBar: AppBar(
          backgroundColor: Nakhwa.background,
          elevation: 0,
          title: const Text(
            'حول التطبيق',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'عن التطبيق:',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'تطبيق نخوة هو خدمة تهدف إلى مساعدة الأفراد، خاصة الطلاب السعوديين المبتعثين حول العالم، بالإضافة إلى الزوار والمسافرين الذين قد يواجهون حالات طارئة أو أزمات. يعمل التطبيق على توفير المعلومات الحيوية بشكل فوري، مما يساعد المستخدمين على تقليل تأثير القرارات واتخاذ قرارات أفضل عند مواجهة ظروف غير مستقرّة.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'خدمات التطبيق:',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• الرسائل الطارئة: يصدر التطبيق تنبيهات عبر الرسائل النصية والبريد الإلكتروني عند وقوع حالات طارئة مثل الكوارث الطبيعية أو التهديدات الأمنية.\n'
                '• أداة السلامة: يقدم التطبيق معلومات وإرشادات تساعد المستخدمين على التصرف بشكل آمن أثناء الأزمات مثل الزلازل أو الفيضانات وغيرها.\n'
                '• خريطة الإغاثات: يمكن للمستخدمين تحديد مواقع أقرب العلاجات والمستشفيات والخدمات الأساسية في حالات الطوارئ.\n'
                '• طلبات المساعدة عبر زر SOS: يوفر زر SOS الذي يمكن المستخدمين من طلب المساعدة بسرعة وسهولة بنقرة واحدة.\n'
                '• الاستشارات القانونية: يتيح الوصول السريع إلى استشارات قانونية، سواء بشكل فوري في حال التهديد القانوني، أو من خلال الربط مع محامٍ مرخص معتمد.\n'
                '• التواصل مع السفارات: يساعد التطبيق المستخدمين على التواصل مع السفارات والقنصليات بشكل مباشر.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'التفعيل عبر السمات الحيوية:',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'لضمان حماية حسابات المستخدمين والخدمات الحساسة، يتطلب التطبيق التحقق من الهوية باستخدام الخصائص الحيوية مثل بصمة الإصبع أو التعرف على الوجه عند تسجيل الدخول أو عند طلب المساعدة الطارئة أو الاستشارة القانونية.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'التحقق عبر السمات الحيوية:',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يقوم التطبيق بالتعرف على المستخدم من خلال سماته الحيوية، ومن ثم يسمح له بالوصول إلى بياناته الشخصية والخيارات الحساسة، مع ضمان حماية المعلومات ومنع أي شخص آخر من استخدامها.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
