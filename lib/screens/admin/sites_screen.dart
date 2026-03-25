import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../models/client_site.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminSitesScreen extends StatefulWidget {
  const AdminSitesScreen({super.key});
  @override
  State<AdminSitesScreen> createState() => _AdminSitesScreenState();
}

class _AdminSitesScreenState extends State<AdminSitesScreen> {
  String _search = '';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final sites = MockDataService.sites.where((s) {
      final matchSearch = _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase()) || s.clientName.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == 'All' || s.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                const AdminTopBar(title: 'Client Sites'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Client Sites', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                              Text('All contracted security sites across Lusaka', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ]),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Site'),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), textStyle: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Summary bar
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 600 ? 3 : 1;
                          return Wrap(spacing: 16, runSpacing: 16, children: [
                            SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SiteSummaryCard(label: 'Total Sites', value: '${MockDataService.sites.length}', icon: Icons.apartment, color: AppColors.primary)),
                            SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SiteSummaryCard(label: 'Active Sites', value: '${MockDataService.sites.where((s) => s.status == "Active").length}', icon: Icons.check_circle, color: AppColors.success)),
                            SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SiteSummaryCard(label: 'Guards Deployed', value: '${MockDataService.sites.fold(0, (a, b) => a + b.guardsDeployed)}', icon: Icons.people, color: AppColors.info)),
                          ]);
                        }),

                        const SizedBox(height: 20),

                        // Search + filter row
                        Row(children: [
                          Expanded(child: TextField(
                            onChanged: (v) => setState(() => _search = v),
                            decoration: const InputDecoration(
                              hintText: 'Search sites or clients...',
                              prefixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          )),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 160,
                            child: DropdownButtonFormField<String>(
                              value: _statusFilter,
                              dropdownColor: AppColors.surface,
                              decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              items: ['All', 'Active', 'Pending', 'Suspended'].map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Sites grid
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 800 ? 2 : 1;
                          return Wrap(
                            spacing: 16, runSpacing: 16,
                            children: sites.map((s) => SizedBox(
                              width: (c.maxWidth - (cols - 1) * 16) / cols,
                              child: _SiteCard(site: s),
                            )).toList(),
                          );
                        }),

                        if (sites.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(48), child: Text('No sites match the current filters.', style: TextStyle(color: AppColors.textMuted)))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SiteSummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SiteSummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ]),
    ]),
  );
}

class _SiteCard extends StatelessWidget {
  final ClientSite site;
  const _SiteCard({required this.site});

  Color get _statusColor => site.status == 'Active' ? AppColors.success : site.status == 'Pending' ? AppColors.warning : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.apartment, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(site.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(site.clientName, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(site.status, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.location_on, color: AppColors.textMuted, size: 13),
          const SizedBox(width: 5),
          Expanded(child: Text(site.address, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.security, color: AppColors.textMuted, size: 13),
          const SizedBox(width: 5),
          Text('${site.serviceType}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatPill(label: 'Guards', value: '${site.guardsDeployed}', color: AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _StatPill(label: 'Contract End', value: site.contractEnd, color: AppColors.info)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('View Details', style: TextStyle(fontSize: 12)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text('Manage', style: TextStyle(fontSize: 12)))),
        ]),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  );
}
