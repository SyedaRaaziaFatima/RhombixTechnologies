import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CollegeAlert {
  const CollegeAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.eventDate,
    required this.isImportant,
    required this.createdAt,
    this.eventTime,
    this.venue,
    this.targetDepartment,
    this.targetSemester,
    this.createdBy,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime eventDate;
  final String? eventTime;
  final String? venue;
  final bool isImportant;
  final String? targetDepartment;
  final String? targetSemester;
  final String? createdBy;
  final DateTime createdAt;

  factory CollegeAlert.fromMap(Map<String, dynamic> map) => CollegeAlert(
        id: map['id']?.toString() ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        category: map['category'] as String? ?? 'General',
        eventDate: _asDate(map['event_date']),
        eventTime: map['event_time']?.toString(),
        venue: map['venue'] as String?,
        isImportant: map['is_important'] as bool? ?? false,
        targetDepartment: map['target_department'] as String?,
        targetSemester: map['target_semester'] as String?,
        createdBy: map['created_by'] as String?,
        createdAt: _asDate(map['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'event_date': Timestamp.fromDate(eventDate),
        'event_time': eventTime?.trim().isEmpty == true ? null : eventTime?.trim(),
        'venue': venue?.trim().isEmpty == true ? null : venue?.trim(),
        'is_important': isImportant,
        'target_department':
            targetDepartment?.trim().isEmpty == true ? null : targetDepartment,
        'target_semester':
            targetSemester?.trim().isEmpty == true ? null : targetSemester,
        'created_by': createdBy,
      };

  static DateTime _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  String get formattedDate =>
      '${eventDate.day.toString().padLeft(2, '0')}/'
      '${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year}';

  IconData get icon => switch (category) {
        'Exam' => Icons.assignment_outlined,
        'Event' => Icons.celebration_outlined,
        'Holiday' => Icons.beach_access_outlined,
        'Fee' => Icons.payments_outlined,
        'Emergency' => Icons.warning_amber_rounded,
        _ => Icons.campaign_outlined,
      };

  Color get color => switch (category) {
        'Exam' => const Color(0xFF6941C6),
        'Event' => const Color(0xFF087E8B),
        'Holiday' => const Color(0xFFEC8B28),
        'Fee' => const Color(0xFF027A48),
        'Emergency' => const Color(0xFFD92D20),
        _ => const Color(0xFF155EEF),
      };
}
