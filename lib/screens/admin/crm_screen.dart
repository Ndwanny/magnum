import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminCrmScreen extends StatefulWidget {
  const AdminCrmScreen({super.key});
  @override
  State<AdminCrmScreen> createState() => _AdminCrmScreenState();
}

class _AdminCrmScreenState extends State<AdminCrmScreen> {
  String _view = 'Kanban';
  final fmt = NumberFormat('#,##0', 'en_US');

  static const _stages = ['New', 'Contacted', 'Quoted', 'Negotiating', 'Won', 'Lost'];

  Color _stageColor(String s) {
    switch (s) {
      case 'New':          return AppColors.info;
      case 'Contacted':    return AppColors.primary;
      case 'Quoted':       return const Color(0xFF9C6FDE);
      case 'Negotiating':  return AppColors.warning;
      case 'Won':          return AppColors.success;
      case 'Lost':         return AppColors.error;
      default:             return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final leads = MockDataExt.leads;

    // Pipeline value summary
    double pipelineValue = leads.where((l) => !['Won','Lost'].contains(l.stage)).fold(0.0, (a, l) => a + (l.quotedValue ?? 0));
    double wonValue      = leads.where((l) => l.stage == 'Won').fold(0.0, (a, l) => a + (l.quotedValue ?? 0));
    int wonCount         = leads.where((l) => l.stage == 'Won').length;
    int totalCount       = leads.where((l) => l.stage != 'Lost').length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(children: [
        if (isDesktop) const AdminSidebar(),
        Expanded(child: Column(children: [
          const AdminTopBar(title: 'CRM Pipeline'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CRM Pipeline', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('Quote & lead tracking — Lusaka prospect management', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ]),
                Row(children: [
                  _ViewToggle(label: 'Kanban', selected: _view == 'Kanban', onTap: () => setState(() => _view = 'Kanban')),
                  const SizedBox(width: 8),
                  _ViewToggle(label: 'List', selected: _view == 'List', onTap: () => setState(() => _view = 'List')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddLeadDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Lead'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                ]),
              ]),
              const SizedBox(height: 24),

              // Summary row
              LayoutBuilder(builder: (ctx, c) {
                final cols = c.maxWidth > 600 ? 4 : 2;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  SizedBox(width: (c.maxWidth-(cols-1)*12)/cols, child: _CrmKpi(label: 'Active Pipeline', value: 'ZMW ${fmt.format(pipelineValue)}', icon: Icons.trending_up, color: AppColors.primary)),
                  SizedBox(width: (c.maxWidth-(cols-1)*12)/cols, child: _CrmKpi(label: 'Won This Quarter', value: 'ZMW ${fmt.format(wonValue)}', icon: Icons.emoji_events, color: AppColors.success)),
                  SizedBox(width: (c.maxWidth-(cols-1)*12)/cols, child: _CrmKpi(label: 'Win Rate', value: totalCount > 0 ? '${(wonCount / (totalCount) * 100).round()}%' : '—', icon: Icons.percent, color: AppColors.info)),
                  SizedBox(width: (c.maxWidth-(cols-1)*12)/cols, child: _CrmKpi(label: 'Total Leads', value: '${leads.length}', icon: Icons.people_outline, color: AppColors.warning)),
                ]);
              }),
              const SizedBox(height: 28),

              if (_view == 'Kanban') _KanbanView(leads: leads, stages: _stages, stageColor: _stageColor, fmt: fmt)
              else _ListView(leads: leads, stageColor: _stageColor, fmt: fmt),
            ]),
          )),
        ])),
      ]),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    final compCtrl  = TextEditingController();
    final nameCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Lead', style: TextStyle(color: AppColors.textPrimary)),
        content: SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: compCtrl, decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / WhatsApp', prefixIcon: Icon(Icons.phone))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead added to pipeline'), backgroundColor: AppColors.success));
            },
            child: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ViewToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textMuted, fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    ),
  );
}

class _CrmKpi extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _CrmKpi({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _KanbanView extends StatelessWidget {
  final List leads;
  final List<String> stages;
  final Color Function(String) stageColor;
  final NumberFormat fmt;
  const _KanbanView({required this.leads, required this.stages, required this.stageColor, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stages.map((stage) {
          final stageLeads = leads.where((l) => l.stage == stage).toList();
          final color = stageColor(stage);
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(stage, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${stageLeads.length}', style: TextStyle(color: color, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 8),
              ...stageLeads.map((l) => _KanbanCard(lead: l, color: color, fmt: fmt)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final dynamic lead;
  final Color color;
  final NumberFormat fmt;
  const _KanbanCard({required this.lead, required this.color, required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.cardBorder, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(lead.companyName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      Text(lead.contactName, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: AppColors.bgMid, borderRadius: BorderRadius.circular(4)),
        child: Text(lead.serviceInterest, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ),
      if (lead.quotedValue != null) ...[
        const SizedBox(height: 6),
        Text('ZMW ${fmt.format(lead.quotedValue)}/mo', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
      if (lead.followUpDate != null) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.event, color: AppColors.textMuted, size: 11),
          const SizedBox(width: 4),
          Text('Follow up: ${DateFormat("dd MMM").format(lead.followUpDate!)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]),
      ],
    ]),
  );
}

class _ListView extends StatelessWidget {
  final List leads;
  final Color Function(String) stageColor;
  final NumberFormat fmt;
  const _ListView({required this.leads, required this.stageColor, required this.fmt});

  @override
  Widget build(BuildContext context) => Column(
    children: leads.map((l) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Row(children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.companyName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(l.contactName, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Expanded(child: Text(l.serviceInterest, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        Expanded(child: Text(l.quotedValue != null ? 'ZMW ${fmt.format(l.quotedValue)}' : '—', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: stageColor(l.stage).withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
          child: Text(l.stage, style: TextStyle(color: stageColor(l.stage), fontSize: 10, fontWeight: FontWeight.w700)),
        )),
        Expanded(child: Text(l.notes, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ]),
    )).toList(),
  );
}
