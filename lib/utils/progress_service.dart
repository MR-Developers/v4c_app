import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseProgressService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getCompletedContent(String courseName) async {
    final userId = _auth.currentUser!.uid;
    final doc = await _firestore
        .collection('Courseprogress')
        .doc(userId)
        .collection('courseProgress')
        .doc(courseName)
        .get();

    return doc.data()?['completedContent'] ?? {};
  }

  bool isContentCompleted({
    required Map<String, dynamic> completedContent,
    required String week,
    required String day,
    required String contentType,
    required String contentKey,
  }) {
    return completedContent[week]?[day]?[contentType]?[contentKey] == true;
  }

  bool isDayCompleted({
    required Map<String, dynamic> completedContent,
    required Map<String, dynamic> dayContent,
    required String week,
    required String day,
  }) {
    final dayCompleted = completedContent[week]?[day];
    if (dayCompleted == null) return false;

    for (final type in dayContent.keys) {
      final contentItems = dayContent[type];
      if (contentItems is Map) {
        for (final key in contentItems.keys) {
          if (dayCompleted[type]?[key] != true) return false;
        }
      }
    }
    return true;
  }

  bool isWeekCompleted({
    required Map<String, dynamic> completedContent,
    required Map<String, dynamic> weekContent,
    required String week,
  }) {
    for (final day in weekContent.keys) {
      final dayContent = weekContent[day];
      if (dayContent is Map) {
        final completed = isDayCompleted(
          completedContent: completedContent,
          dayContent: Map<String, dynamic>.from(dayContent),
          week: week,
          day: day,
        );
        if (!completed) return false;
      }
    }
    return true;
  }
}
