class PayrollRecord {
  final String id;
  final String guardId;
  final String guardName;
  final String period;     // e.g. 'March 2024'
  final double basicPay;
  final double overtime;
  final double allowances;
  final double napsa;      // 5% employee NAPSA
  final double nhima;      // 1% NHIMA
  final double paye;       // PAYE tax
  final String status;     // 'Pending' | 'Paid' | 'Processing'
  final DateTime? paidAt;

  const PayrollRecord({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.period,
    required this.basicPay,
    required this.overtime,
    required this.allowances,
    required this.napsa,
    required this.nhima,
    required this.paye,
    required this.status,
    this.paidAt,
  });

  double get grossPay   => basicPay + overtime + allowances;
  double get deductions => napsa + nhima + paye;
  double get netPay     => grossPay - deductions;
}
