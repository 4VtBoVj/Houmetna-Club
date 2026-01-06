import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new report
  Future<void> createReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photoUrls,
  }) async {
    try {
      final callable = _functions.httpsCallable('createReport');
      await callable.call({
        'category': category,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'photoUrls': photoUrls ?? [],
      });
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  // Get current user's reports
  Stream<List<Report>> getUserReports() {
    final userId = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    });
  }

  // Get all reports (for map view)
  Stream<List<Report>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    });
  }

  // Get single report
  Future<Report?> getReport(String reportId) async {
    try {
      final doc = await _firestore
          .collection('reports')
          .doc(reportId)
          .get();
      if (doc.exists) {
        return Report.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }
}
