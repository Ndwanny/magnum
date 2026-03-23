import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../models/guard.dart';
import '../../utils/constants.dart';
import 'admin_dashboard_screen.dart';

class AdminGuardsScreen extends StatefulWidget {
  const AdminGuardsScreen({super.key});
  @override
  State<AdminGuardsScreen> createState() => _AdminGuardsScreenState();
}

class _AdminGuardsScreenState extends State<AdminGuardsScreen> {
  String _search = '';
  String _statusFilter = 'All';
  String _roleFilter   = 'All';
  Guard? _selected;

  final _statuses = ['All', 'Active', 'On Leave', 'Off Duty'];
  final _roles    = ['All', 'Supervisor', 'Armed', 'Unarmed'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final guards = MockDataService.guards.where((g) {
      final matchSearch = _search.isEmpty || g.name.toLowerCase().contains(_search.toLowerCase()) || g.badgeNumber.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == 'All' || g.status == _statusFilter;
      final matchRole   = _roleFilter == 'All' || g.role == _roleFilter;
      return matchSearch && matchStatus && matchRole;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: _selected != null && isDesktop ? 3 : 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                                    Text('Guard Management', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                                    Text('View and manage all security personnel', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  ]),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.person_add, size: 16),
                                    label: const Text('Add Guard'),
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), textStyle: const TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Summary chips
                              Wrap(spacing: 10, runSpacing: 8, children: [
                                _SummaryChip(label: 'Total', value: '${MockDataService.guards.length}', color: AppColors.primary),
                                _SummaryChip(label: 'Active', value: '${MockDataService.guards.where((g) => g.status == "Active").length}', color: AppColors.success),
                                _SummaryChip(label: 'On Leave', value: '${MockDataService.guards.where((g) => g.status == "On Leave").length}', color: AppColors.warning),
                              ]),
                              const SizedBox(height: 20),
                              // Search & filters
                              TextField(
                                onChanged: (v) => setState(() => _search = v),
                                decoration: const InputDecoration(
                                  hintText: 'Search by name or badge number...',
                                  prefixIcon: Icon(Icons.search),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: _DropdownFilter(label: 'Status', value: _statusFilter, items: _statuses, onChanged: (v) => setState(() => _statusFilter = v!))),
                                const SizedBox(width: 12),
                                Expanded(child: _DropdownFilter(label: 'Role', value: _roleFilter, items: _roles, onChanged: (v) => setState(() => _roleFilter = v!))),
                              ]),
                              const SizedBox(height: 20),
                              ...guards.map((g) => _GuardRow(guard: g, selected: _selected?.id == g.id, onTap: () => setState(() => _selected = _selected?.id == g.id ? null : g))),
                              if (guards.isEmpty)
                                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No guards match the current filters.', style: TextStyle(color: AppColors.textMuted)))),
                            ],
                          ),
                        ),
                      ),
                      if (_selected != null && isDesktop)
                        Container(
                          width: 300,
                          decoration: const BoxDecoration(
                            color: AppColors.bgMid,
                            border: Border(left: BorderSide(color: AppColors.divider)),
                          ),
                          child: _GuardDetail(guard: _selected!, onClose: () => setState(() => _selected = null)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
    ]),
  );
}

class _DropdownFilter extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownFilter({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    dropdownColor: AppColors.surface,
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
    onChanged: onChanged,
  );
}

class _GuardRow extends StatelessWidget {
  final Guard guard;
  final bool selected;
  final VoidCallback onTap;
  const _GuardRow({required this.guard, required this.selected, required this.onTap});

  Color get _statusColor => guard.status == 'Active' ? AppColors.success : guard.status == 'On Leave' ? AppColors.warning : AppColors.textMuted;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? AppColors.primary.withOpacity(0.5) : AppColors.cardBorder, width: selected ? 1.5 : 0.5),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text(guard.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(guard.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('${guard.badgeNumber}  •  ${guard.role}  •  ${guard.currentSite}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(guard.status, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      ]),
    ),
  );
}

class _GuardDetail extends StatelessWidget {
  final Guard guard;
  final VoidCallback onClose;
  const _GuardDetail({required this.guard, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final statusColor = guard.status == 'Active' ? AppColors.success : guard.status == 'On Leave' ? AppColors.warning : AppColors.textMuted;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Guard Profile', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18), onPressed: onClose),
        ]),
        const SizedBox(height: 16),
        Center(child: Column(children: [
          CircleAvatar(radius: 36, backgroundColor: AppColors.primary.withOpacity(0.2), child: Text(guard.name[0], style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w800))),
          const SizedBox(height: 12),
          Text(guard.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(guard.badgeNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(guard.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ])),
        const SizedBox(height: 24),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 16),
        _DetailRow(label: 'Role', value: guard.role),
        _DetailRow(label: 'Current Site', value: guard.currentSite),
        _DetailRow(label: 'Phone', value: guard.phone),
        _DetailRow(label: 'Email', value: guard.email),
        _DetailRow(label: 'Joined', value: guard.joinDate),
        const SizedBox(height: 20),
        const Text('CERTIFICATIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: guard.certifications.map((c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
          child: Text(c, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
        )).toList()),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 15), label: const Text('Edit Profile'))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_month, size: 15), label: const Text('View Schedule'))),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
      Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
    ]),
  );
}
