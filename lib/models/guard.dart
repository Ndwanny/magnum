class Guard {
  final String id;
  final String name;
  final String badgeNumber;
  final String phone;
  final String email;
  final String role;          // 'Armed' | 'Unarmed' | 'Supervisor'
  final String status;        // 'Active' | 'On Leave' | 'Off Duty'
  final String currentSite;
  final String joinDate;
  final String photoUrl;
  final List<String> certifications;

  const Guard({
    required this.id,
    required this.name,
    required this.badgeNumber,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.currentSite,
    required this.joinDate,
    required this.photoUrl,
    required this.certifications,
  });
}
