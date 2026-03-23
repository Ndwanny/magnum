class AttendanceRecord {
  final String id;
  final String guardId;
  final String guardName;
  final String guardBadge;
  final String site;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String status; // 'Present' | 'Late' | 'Absent' | 'On Leave'
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.guardBadge,
    required this.site,
    required this.date,
    this.clockIn,
    this.clockOut,
    required this.status,
    this.notes,
  });

  Duration? get hoursWorked =>
      clockIn != null && clockOut != null ? clockOut!.difference(clockIn!) : null;
}
