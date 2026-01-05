import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Report {
  final String id;
  final String userId;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String status; // new, in-progress, resolved
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Report({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.photoUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'new',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Color getStatusColor() {
    switch (status) {
      case 'in-progress':
        return const Color(0xFF2196F3); // Blue
      case 'resolved':
        return const Color(0xFF4CAF50); // Green
      case 'new':
      default:
        return const Color(0xFFFFA500); // Orange
    }
  }

  String getStatusLabel() {
    switch (status) {
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'new':
      default:
        return 'New';
    }
  }
}
