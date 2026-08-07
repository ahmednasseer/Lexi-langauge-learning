import 'package:cloud_firestore/cloud_firestore.dart';

class LessonRepository {
  static final LessonRepository _instance = LessonRepository._internal();
  factory LessonRepository() => _instance;
  LessonRepository._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final snapshot = await _db.collection('lessons').get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLessonsByUnit(String unitId) async {
    try {
      final snapshot = await _db
          .collection('lessons')
          .where('unitId', isEqualTo: unitId)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getLesson(String lessonId) async {
    try {
      final doc = await _db.collection('lessons').doc(lessonId).get();
      return doc.data() ?? {};
    } catch (_) {
      return {};
    }
  }
}
