class QCLog {
  final String id;
  final String subtitleFileId;
  final String qcUser;
  final int lineNumber;
  final String errorType;
  final String correctionNote;
  final DateTime createdAt;

  QCLog({
    required this.id,
    required this.subtitleFileId,
    required this.qcUser,
    required this.lineNumber,
    required this.errorType,
    required this.correctionNote,
    required this.createdAt,
  });

  factory QCLog.fromJson(Map<String, dynamic> json) {
    return QCLog(
      id: json['id'],
      subtitleFileId: json['subtitle_file_id'],
      qcUser: json['qc_user'],
      lineNumber: json['line_number'],
      errorType: json['error_type'],
      correctionNote: json['correction_note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Attendance {
  final String id;
  final String userId;
  final DateTime date;
  final int filesCompleted;
  final double attendancePoints;
  final double bonusPoints;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    required this.filesCompleted,
    required this.attendancePoints,
    required this.bonusPoints,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      filesCompleted: json['files_completed'] ?? 0,
      attendancePoints: (json['attendance_points'] ?? 0).toDouble(),
      bonusPoints: (json['bonus_points'] ?? 0).toDouble(),
    );
  }
}
