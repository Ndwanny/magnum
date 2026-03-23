import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class EmergencyFAB extends StatelessWidget {
  const EmergencyFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(context),
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.emergency, size: 20),
      label: const Text('Emergency', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: const [
          Icon(Icons.emergency, color: AppColors.error),
          SizedBox(width: 8),
          Text('Emergency Contact', style: TextStyle(color: AppColors.textPrimary)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Column(children: [
                Text('EMERGENCY HOTLINE', style: TextStyle(color: AppColors.error, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('0800 123 456', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
                Text('Available 24/7 — Free to call', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('For non-emergency issues, contact your site supervisor or call our office number.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
}
