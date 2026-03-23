class ClientSite {
  final String id;
  final String name;
  final String address;
  final String clientName;
  final int guardsDeployed;
  final String serviceType;
  final String status;      // 'Active' | 'Suspended' | 'Pending'
  final String contractEnd;

  const ClientSite({
    required this.id,
    required this.name,
    required this.address,
    required this.clientName,
    required this.guardsDeployed,
    required this.serviceType,
    required this.status,
    required this.contractEnd,
  });
}
