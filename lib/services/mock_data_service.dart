import '../models/guard.dart';
import '../models/incident.dart';
import '../models/client_site.dart';
import '../models/invoice.dart';
import '../models/patrol_log.dart';


class MockDataService {
  static final List<Guard> guards = [
    const Guard(id: 'G001', name: 'Chanda Mwamba', badgeNumber: 'MS-001', phone: '+260 977 111 222', email: 'c.mwamba@magnumsecurity.co.zm', role: 'Supervisor', status: 'Active', currentSite: 'Manda Hill Mall', joinDate: '2019-03-15', photoUrl: '', certifications: ['ZAPS Grade A', 'First Aid', 'Firearms']),
    const Guard(id: 'G002', name: 'Bwalya Kasonde', badgeNumber: 'MS-002', phone: '+260 977 222 333', email: 'b.kasonde@magnumsecurity.co.zm', role: 'Armed', status: 'Active', currentSite: 'Arcades Shopping', joinDate: '2020-07-10', photoUrl: '', certifications: ['ZAPS Grade B', 'Firearms']),
    const Guard(id: 'G003', name: 'Mutale Phiri', badgeNumber: 'MS-003', phone: '+260 977 333 444', email: 'm.phiri@magnumsecurity.co.zm', role: 'Unarmed', status: 'Active', currentSite: 'East Park Mall', joinDate: '2021-01-20', photoUrl: '', certifications: ['ZAPS Grade C', 'First Aid']),
    const Guard(id: 'G004', name: 'Inonge Lungu', badgeNumber: 'MS-004', phone: '+260 977 444 555', email: 'i.lungu@magnumsecurity.co.zm', role: 'Armed', status: 'On Leave', currentSite: '-', joinDate: '2020-11-05', photoUrl: '', certifications: ['ZAPS Grade B', 'Firearms', 'Dog Handling']),
    const Guard(id: 'G005', name: 'Mwansa Tembo', badgeNumber: 'MS-005', phone: '+260 977 555 666', email: 'm.tembo@magnumsecurity.co.zm', role: 'Unarmed', status: 'Active', currentSite: 'Levy Junction', joinDate: '2022-04-18', photoUrl: '', certifications: ['ZAPS Grade C']),
    const Guard(id: 'G006', name: 'Nkandu Banda', badgeNumber: 'MS-006', phone: '+260 977 666 777', email: 'n.banda@magnumsecurity.co.zm', role: 'Supervisor', status: 'Active', currentSite: 'UTH Complex', joinDate: '2018-09-01', photoUrl: '', certifications: ['ZAPS Grade A', 'First Aid', 'Firearms', 'Crowd Control']),
  ];

  static final List<Incident> incidents = [
    Incident(id: 'INC001', title: 'Suspicious Vehicle — Perimeter Check', description: 'Unregistered vehicle parked near gate 3 for over 2 hours. Guard conducted identification check. Owner identified as contractor. No further action required.', severity: 'Low', status: 'Resolved', site: 'Manda Hill Mall', reportedBy: 'Chanda Mwamba', reportedAt: DateTime.now().subtract(const Duration(hours: 3)), resolvedBy: 'Chanda Mwamba', resolvedAt: DateTime.now().subtract(const Duration(hours: 2))),
    Incident(id: 'INC002', title: 'Attempted Break-in — East Entrance', description: 'Two individuals attempted to force the east entrance fire door at approximately 02:15. Alarm triggered. Suspects fled before police arrival. CCTV footage preserved.', severity: 'High', status: 'In Progress', site: 'Arcades Shopping', reportedBy: 'Bwalya Kasonde', reportedAt: DateTime.now().subtract(const Duration(hours: 10)), resolvedBy: null, resolvedAt: null),
    Incident(id: 'INC003', title: 'Medical Emergency — Staff Member', description: 'Staff member collapsed near food court. First aid administered by Guard Phiri. Ambulance called and patient transported to UTH. Family notified.', severity: 'Medium', status: 'Closed', site: 'East Park Mall', reportedBy: 'Mutale Phiri', reportedAt: DateTime.now().subtract(const Duration(days: 1)), resolvedBy: 'Mutale Phiri', resolvedAt: DateTime.now().subtract(const Duration(hours: 22))),
    Incident(id: 'INC004', title: 'Shoplifting Incident', description: 'Individual apprehended attempting to exit without paying for electronics. Police called. Item recovered. Individual taken into custody.', severity: 'Medium', status: 'Closed', site: 'Levy Junction', reportedBy: 'Mwansa Tembo', reportedAt: DateTime.now().subtract(const Duration(days: 2)), resolvedBy: 'Mwansa Tembo', resolvedAt: DateTime.now().subtract(const Duration(days: 1, hours: 20))),
    Incident(id: 'INC005', title: 'CCTV Camera Fault — Zone B', description: 'Three cameras in Zone B stopped transmitting. Maintenance team notified. Manual patrols increased in affected area pending repair.', severity: 'Low', status: 'Open', site: 'UTH Complex', reportedBy: 'Nkandu Banda', reportedAt: DateTime.now().subtract(const Duration(hours: 6)), resolvedBy: null, resolvedAt: null),
  ];

  static final List<ClientSite> sites = [
    const ClientSite(id: 'S001', name: 'Manda Hill Mall', address: 'Great East Road, Lusaka', clientName: 'Manda Hill Management Ltd', guardsDeployed: 12, serviceType: 'Armed + CCTV', status: 'Active', contractEnd: '2025-12-31'),
    const ClientSite(id: 'S002', name: 'Arcades Shopping Centre', address: 'Great East Road, Lusaka', clientName: 'Arcades Investments', guardsDeployed: 8, serviceType: 'Armed + Unarmed', status: 'Active', contractEnd: '2025-06-30'),
    const ClientSite(id: 'S003', name: 'East Park Mall', address: 'Thabo Mbeki Road, Lusaka', clientName: 'East Park Retail Ltd', guardsDeployed: 6, serviceType: 'Unarmed + CCTV', status: 'Active', contractEnd: '2026-01-15'),
    const ClientSite(id: 'S004', name: 'Levy Junction', address: 'Alick Nkhata Road, Lusaka', clientName: 'Levy Junction Ltd', guardsDeployed: 5, serviceType: 'Unarmed', status: 'Active', contractEnd: '2025-09-30'),
    const ClientSite(id: 'S005', name: 'UTH Complex', address: 'Nationalist Road, Lusaka', clientName: 'Ministry of Health', guardsDeployed: 10, serviceType: 'Armed + Unarmed', status: 'Active', contractEnd: '2025-12-31'),
    const ClientSite(id: 'S006', name: 'Woodlands Hotel', address: 'Alick Nkhata Road, Lusaka', clientName: 'Woodlands Hospitality', guardsDeployed: 4, serviceType: 'Unarmed + Alarm', status: 'Pending', contractEnd: '2025-04-01'),
  ];

  static final List<Invoice> invoices = [
    Invoice(id: 'INV001', invoiceNumber: 'INV-2024-0041', clientName: 'Manda Hill Management Ltd', amount: 185000.0, currency: 'ZMW', status: 'Paid', issuedDate: DateTime(2024, 3, 1), dueDate: DateTime(2024, 3, 15), items: [const InvoiceItem(description: '12 Armed Guards (March 2024)', quantity: 12, unitPrice: 12000), const InvoiceItem(description: 'CCTV Monitoring Service', quantity: 1, unitPrice: 41000)]),
    Invoice(id: 'INV002', invoiceNumber: 'INV-2024-0042', clientName: 'Arcades Investments', amount: 96000.0, currency: 'ZMW', status: 'Pending', issuedDate: DateTime(2024, 3, 1), dueDate: DateTime(2024, 3, 15), items: [const InvoiceItem(description: '8 Guards (March 2024)', quantity: 8, unitPrice: 12000)]),
    Invoice(id: 'INV003', invoiceNumber: 'INV-2024-0040', clientName: 'East Park Retail Ltd', amount: 72000.0, currency: 'ZMW', status: 'Paid', issuedDate: DateTime(2024, 2, 1), dueDate: DateTime(2024, 2, 15), items: [const InvoiceItem(description: '6 Unarmed Guards (Feb 2024)', quantity: 6, unitPrice: 10000), const InvoiceItem(description: 'CCTV Monitoring', quantity: 1, unitPrice: 12000)]),
    Invoice(id: 'INV004', invoiceNumber: 'INV-2024-0039', clientName: 'Ministry of Health', amount: 130000.0, currency: 'ZMW', status: 'Overdue', issuedDate: DateTime(2024, 2, 1), dueDate: DateTime(2024, 2, 15), items: [const InvoiceItem(description: '10 Guards — UTH Complex (Feb 2024)', quantity: 10, unitPrice: 13000)]),
  ];

  static final List<PatrolLog> patrolLogs = [
    PatrolLog(id: 'PL001', guardName: 'Chanda Mwamba', guardBadge: 'MS-001', site: 'Manda Hill Mall', startTime: DateTime.now().subtract(const Duration(hours: 2)), endTime: DateTime.now().subtract(const Duration(hours: 1)), checkpoints: [CheckpointEntry(checkpointName: 'Main Entrance', scannedAt: DateTime.now().subtract(const Duration(hours: 2)), isOk: true), CheckpointEntry(checkpointName: 'Parking Level 1', scannedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)), isOk: true), CheckpointEntry(checkpointName: 'East Wing', scannedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), isOk: true), CheckpointEntry(checkpointName: 'Rooftop Access', scannedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)), isOk: true)], notes: 'All clear. No anomalies observed.', status: 'Completed'),
    PatrolLog(id: 'PL002', guardName: 'Bwalya Kasonde', guardBadge: 'MS-002', site: 'Arcades Shopping', startTime: DateTime.now().subtract(const Duration(hours: 1)), endTime: null, checkpoints: [CheckpointEntry(checkpointName: 'Front Gate', scannedAt: DateTime.now().subtract(const Duration(minutes: 55)), isOk: true), CheckpointEntry(checkpointName: 'Loading Bay', scannedAt: DateTime.now().subtract(const Duration(minutes: 40)), isOk: true)], notes: 'Patrol in progress.', status: 'Ongoing'),
  ];


}

// Extended mock data (separate to keep class size manageable)
class MockDataExt {
  static List<dynamic> get attendance {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      _att('A001','G001','Chanda Mwamba','MS-001','Manda Hill Mall', today.add(const Duration(hours:6)), today.add(const Duration(hours:18)), 'Present','Day'),
      _att('A002','G002','Bwalya Kasonde','MS-002','Arcades Shopping', today.subtract(const Duration(hours:2)), null, 'Present','Night'),
      _att('A003','G003','Mutale Phiri','MS-003','East Park Mall', today.add(const Duration(hours:7,minutes:22)), today.add(const Duration(hours:19)), 'Late','Day'),
      _att('A004','G005','Mwansa Tembo','MS-005','Levy Junction', today.add(const Duration(hours:6)), today.add(const Duration(hours:18)), 'Present','Day'),
      _att('A005','G006','Nkandu Banda','MS-006','UTH Complex', today.add(const Duration(hours:6)), today.add(const Duration(hours:18)), 'Present','Day'),
      _att('A006','G004','Inonge Lungu','MS-004','-', today, null, 'On Leave','Day'),
      _att('A007','G001','Chanda Mwamba','MS-001','Manda Hill Mall', today.subtract(const Duration(days:1,hours:-6)), today.subtract(const Duration(days:1,hours:-18)), 'Present','Day'),
      _att('A008','G003','Mutale Phiri','MS-003','East Park Mall', today.subtract(const Duration(days:1,hours:-8)), today.subtract(const Duration(days:1,hours:-19)), 'Late','Day'),
    ];
  }

  static dynamic _att(String id, String gid, String name, String badge, String site,
      DateTime clockIn, DateTime? clockOut, String status, String shift) {
    return _AttRec(id:id,guardId:gid,guardName:name,guardBadge:badge,site:site,
        clockIn:clockIn,clockOut:clockOut,status:status,shift:shift);
  }

  // ── Payroll ───────────────────────────────────────────────────────────────
  static final List<dynamic> payroll = [
    _PayRec('P001','G001','Chanda Mwamba','March 2024',12000,1800,1200,599,139,2120,'Paid',DateTime(2024,3,28)),
    _PayRec('P002','G002','Bwalya Kasonde','March 2024',12000,2400,1200,578,134,2030,'Paid',DateTime(2024,3,28)),
    _PayRec('P003','G003','Mutale Phiri','March 2024',10000,0,800,540,125,1560,'Processing',null),
    _PayRec('P004','G005','Mwansa Tembo','March 2024',10000,600,800,520,121,1490,'Pending',null),
    _PayRec('P005','G006','Nkandu Banda','March 2024',12000,0,1200,615,143,2240,'Pending',null),
    _PayRec('P006','G004','Inonge Lungu','March 2024',12000,0,0,600,139,0,'Pending',null),
  ];

  // ── CRM Leads ─────────────────────────────────────────────────────────────
  static final List<dynamic> leads = [
    _Lead('L001','Shoprite Zambia','Tatenda Moyo','+260 977 888 001','tatenda@shoprite.co.zm','Armed + CCTV','Negotiating',320000,DateTime(2024,2,15),DateTime(2024,3,20),'Site survey done. Proposal sent. Awaiting board approval.'),
    _Lead('L002','Lusaka Business Park','Kapembwa Ng\'uni','+260 977 888 002','kapembwa@lbp.co.zm','Unarmed Guards','Quoted',144000,DateTime(2024,2,28),DateTime(2024,3,18),'Competitive bid against 2 other firms.'),
    _Lead('L003','Taj Pamodzi Hotel','Priya Sharma','+260 977 888 003','priya@tajpamodzi.co.zm','Armed + Alarm','Contacted',null,DateTime(2024,3,5),DateTime(2024,3,15),'Initial call done. Needs full site assessment.'),
    _Lead('L004','Stanbic Bank — Cairo Rd','Monde Mwila','+260 977 888 004','monde.mwila@stanbic.com','Cash in Transit + Armed','New',null,DateTime(2024,3,12),DateTime(2024,3,19),'Referral from Manda Hill contact.'),
    _Lead('L005','TopFloor Technologies','Chanda Ngosa','+260 977 888 005','chanda@topfloor.co.zm','Unarmed Guards','Won',84000,DateTime(2024,1,10),null,'Contract signed Jan 25. Site goes live April 1.'),
    _Lead('L006','Mukuba Hotel','Bupe Mutale','+260 977 888 006','bupe@mukuba.co.zm','Unarmed + Alarm','Lost',72000,DateTime(2024,1,20),null,'Lost to competitor on price. Follow up Q3.'),
  ];

  // ── Messages ──────────────────────────────────────────────────────────────
  static final List<dynamic> channels = [
    _Channel('C001','Operations — All Staff','team',3,[
      _Msg('M001','A001','Admin','Shift briefing at 05:45 tomorrow — Manda Hill site. All day shift guards to report.',DateTime.now().subtract(const Duration(hours:2)),true),
      _Msg('M002','G001','Chanda Mwamba','Confirmed. Will brief the team.',DateTime.now().subtract(const Duration(hours:1,minutes:50)),true),
      _Msg('M003','A001','Admin','Camera 3B at Arcades is offline. Maintenance on site 08:00 Thursday.',DateTime.now().subtract(const Duration(minutes:45)),false),
    ]),
    _Channel('C002','Manda Hill — Site Channel','site',1,[
      _Msg('M004','G001','Chanda Mwamba','Patrol complete. All clear 22:00 round.',DateTime.now().subtract(const Duration(hours:5)),true),
      _Msg('M005','A001','Admin','Good. Ensure gate 3 padlock is checked on every round.',DateTime.now().subtract(const Duration(hours:4,minutes:45)),false),
    ]),
    _Channel('C003','Arcades — Site Channel','site',0,[
      _Msg('M006','G002','Bwalya Kasonde','Suspicious vehicle noted and logged. Reg: ABZ 1234. Police informed.',DateTime.now().subtract(const Duration(hours:10)),true),
    ]),
    _Channel('C004','Supervisors Only','team',2,[
      _Msg('M007','G006','Nkandu Banda','Need 2 extra guards for UTH Saturday. Any volunteers?',DateTime.now().subtract(const Duration(hours:3)),true),
      _Msg('M008','G001','Chanda Mwamba','I can do it. Overtime approved?',DateTime.now().subtract(const Duration(hours:2,minutes:30)),false),
    ]),
  ];
}

// Thin data classes (replaces typed models to keep this file self-contained)
class _AttRec {
  final String id,guardId,guardName,guardBadge,site,status,shift;
  final DateTime clockIn;
  final DateTime? clockOut;
  const _AttRec({required this.id,required this.guardId,required this.guardName,required this.guardBadge,required this.site,required this.clockIn,this.clockOut,required this.status,required this.shift});
  Duration? get hoursWorked => clockOut != null ? clockOut!.difference(clockIn) : null;
}
class _PayRec {
  final String id,guardId,guardName,period,status;
  final double basicPay,overtime,allowances,napsa,nhima,paye;
  final DateTime? paidAt;
  const _PayRec(this.id,this.guardId,this.guardName,this.period,this.basicPay,this.overtime,this.allowances,this.napsa,this.nhima,this.paye,this.status,this.paidAt);
  double get grossPay   => basicPay + overtime + allowances;
  double get deductions => napsa + nhima + paye;
  double get netPay     => grossPay - deductions;
}
class _Lead {
  final String id,companyName,contactName,phone,email,serviceInterest,stage,notes;
  final double? quotedValue;
  final DateTime createdAt;
  final DateTime? followUpDate;
  const _Lead(this.id,this.companyName,this.contactName,this.phone,this.email,this.serviceInterest,this.stage,this.quotedValue,this.createdAt,this.followUpDate,this.notes);
}
class _Channel {
  final String id,name,type;
  final int unread;
  final List<_Msg> messages;
  const _Channel(this.id,this.name,this.type,this.unread,this.messages);
}
class _Msg {
  final String id,senderId,senderName,content;
  final DateTime sentAt;
  final bool isRead;
  const _Msg(this.id,this.senderId,this.senderName,this.content,this.sentAt,this.isRead);
}

