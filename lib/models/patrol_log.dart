class PatrolLog {
  final String id;
  final String guardName;
  final String guardBadge;
  final String site;
  final DateTime startTime;
  final DateTime? endTime;
  final List<CheckpointEntry> checkpoints;
  final String notes;
  final String status;   // 'Ongoing' | 'Completed' | 'Missed'

  const PatrolLog({
    required this.id,
    required this.guardName,
    required this.guardBadge,
    required this.site,
    required this.startTime,
    this.endTime,
    required this.checkpoints,
    required this.notes,
    required this.status,
  });
}

class CheckpointEntry {
  final String checkpointName;
  final DateTime scannedAt;
  final bool isOk;

  const CheckpointEntry({
    required this.checkpointName,
    required this.scannedAt,
    required this.isOk,
  });
}
