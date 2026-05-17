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
      id: json["id"],
      userId: json["user_id"],
      date: DateTime.parse(json["date"]),
      filesCompleted: json["files_completed"] ?? 0,
      attendancePoints: (json["attendance_points"] ?? 0).toDouble(),
      bonusPoints: (json["bonus_points"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "date": date.toIso8601String().split("T").first, // Store date only
    "files_completed": filesCompleted,
    "attendance_points": attendancePoints,
    "bonus_points": bonusPoints,
  };
}
