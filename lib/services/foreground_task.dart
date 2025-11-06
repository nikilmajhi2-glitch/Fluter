import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'firebase_service.dart';
import 'sms_service.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(SmsTaskHandler());
}

class SmsTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    while (true) {
      final tasks = await FirebaseService.getPendingSmsTasks().first;
      for (var task in tasks) {
        if (!task.sent) {
          await SmsService.sendSms(task.recipient, task.message, task.id);
        }
      }
      await Future.delayed(Duration(seconds: 10));
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}
}
