class CrmLead {
  final String id;
  final String companyName;
  final String contactName;
  final String phone;
  final String email;
  final String serviceInterest;
  final String stage; // 'New' | 'Contacted' | 'Quoted' | 'Negotiating' | 'Won' | 'Lost'
  final double? quotedValue;   // ZMW
  final DateTime createdAt;
  final DateTime? followUpDate;
  final String notes;

  const CrmLead({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.serviceInterest,
    required this.stage,
    this.quotedValue,
    required this.createdAt,
    this.followUpDate,
    required this.notes,
  });
}
