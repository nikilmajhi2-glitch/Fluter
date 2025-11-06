import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/firebase_service.dart';
import '../services/foreground_task.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class HomeScreen extends StatefulWidget {
  @override _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
  }

  void _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sms_service_channel',
        channelName: 'SMS Auto Sender',
        channelDescription: 'Running in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _startService(String userId) async {
    if (!await _requestPermissions()) return;

    final valid = await FirebaseService.verifyUserId(userId);
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid User ID")));
      return;
    }

    await FirebaseService.saveUserId(userId);
    await FlutterForegroundTask.startService(
      notificationTitle: 'SMS Auto Sender',
      notificationText: 'Service Running',
      callback: startCallback,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Started")));
  }

  Future<bool> _requestPermissions() async {
    final permissions = [Permission.sms, Permission.phone];
    final results = await Future.wait(permissions.map((p) => p.request()));
    return results.every((status) => status.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS Auto Sender")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter User ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                await _startService(_controller.text.trim());
                setState(() => _isLoading = false);
              },
              child: _isLoading ? CircularProgressIndicator() : Text("Start Service"),
            ),
          ],
        ),
      ),
    );
  }
}
