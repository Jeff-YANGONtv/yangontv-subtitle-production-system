enum FileStatus { assigned, pending, approved, rejected }

class SubtitleFile {
  final String id;
  final String fileName;
  final String assignedEditor;
  final int totalErrors;
  final int missedErrors;
  final int correctedLines;
  final FileStatus status;
  final DateTime? submissionDate;
  final String? qcNotes;
  final double deductionAmount;
  final DateTime createdAt;

  SubtitleFile({
    required this.id,
    required this.fileName,
    required this.assignedEditor,
    this.totalErrors = 0,
    this.missedErrors = 0,
    this.correctedLines = 0,
    required this.status,
    this.submissionDate,
    this.qcNotes,
    this.deductionAmount = 0,
    required this.createdAt,
  });

  factory SubtitleFile.fromJson(Map<String, dynamic> json) {
    return SubtitleFile(
      id: json['id'],
      fileName: json['file_name'],
      assignedEditor: json['assigned_editor'],
      totalErrors: json['total_errors'] ?? 0,
      missedErrors: json['missed_errors'] ?? 0,
      correctedLines: json['corrected_lines'] ?? 0,
      status: FileStatus.values.firstWhere((e) => e.name == json['status']),
      submissionDate: json['submission_date'] != null ? DateTime.parse(json['submission_date']) : null,
      qcNotes: json['qc_notes'],
      deductionAmount: (json['deduction_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'assigned_editor': assignedEditor,
    'total_errors': totalErrors,
    'missed_errors': missedErrors,
    'corrected_lines': correctedLines,
    'status': status.name,
    'submission_date': submissionDate?.toIso8601String(),
    'qc_notes': qcNotes,
    'deduction_amount': deductionAmount,
    'created_at': createdAt.toIso8601String(),
  };
}
