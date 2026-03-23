class Incident {
  final String id;
  final String title;
  final String description;
  final String severity;    // 'Low' | 'Medium' | 'High' | 'Critical'
  final String status;      // 'Open' | 'In Progress' | 'Resolved' | 'Closed'
  final String site;
  final String reportedBy;
  final DateTime reportedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.site,
    required this.reportedBy,
    required this.reportedAt,
    this.resolvedBy,
    this.resolvedAt,
  });
}
