import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Report {
  final String id;
  final String userId;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
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
    DateTime _toDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is double)
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'new',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: _toDate(data['createdAt']),
      updatedAt: (() {
        final v = data['updatedAt'];
        if (v == null) return null;
        if (v is Timestamp) return v.toDate();
        if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
        if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
        if (v is String) return DateTime.tryParse(v);
        return null;
      })(),
    );
  }

  Color getStatusColor() {
    switch (status) {
      case 'in-progress':
        return const Color(0xFF2196F3);
      case 'resolved':
        return const Color(0xFF4CAF50);
      case 'new':
      default:
        return const Color(0xFFFFA500);
    }
  }

  String get location {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
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
