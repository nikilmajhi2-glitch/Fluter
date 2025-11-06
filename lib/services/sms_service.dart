import 'package:sms_advanced/sms_advanced.dart';
import 'firebase_service.dart';

class SmsService {
  static Future<void> sendSms(String phone, String message, String docId) async {
    try {
      final sms = SmsMessage(phone, message);
      sms.onStateChanged.listen((state) async {
        if (state == SmsMessageState.Sent) {
          await FirebaseService.deleteTask(docId);
        } else if (state == SmsMessageState.Failed) {
          print("SMS Failed: $docId");
        }
      });
      await sms.send();
    } catch (e) {
      print("SMS Send Error: $e");
    }
  }
}
