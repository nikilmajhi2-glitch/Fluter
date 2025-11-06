import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_item.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<bool> verifyUserId(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<void> deductCredit() async {
    final userId = await getUserId();
    if (userId == null) return;

    await _db.collection('users').doc(userId).update({
      'balance': FieldValue.increment(-0.20),
    });
  }

  static Stream<List<SmsItem>> getPendingSmsTasks() {
    return _db.collection('sms_tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SmsItem.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  static Future<void> deleteTask(String docId) async {
    await _db.collection('sms_tasks').doc(docId).delete();
    await deductCredit();
  }
}
