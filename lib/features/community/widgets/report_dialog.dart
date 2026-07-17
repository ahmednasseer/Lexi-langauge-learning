import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import '../security_service.dart';

class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String? messageId;
  final Function(UserReport) onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    this.messageId,
    required this.onReportSubmitted,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  final SecurityService _securityService = SecurityService();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_selectedReason == null) return;

    final report = _securityService.reportUser(
      reporterId: 'current_user',
      reportedUserId: widget.reportedUserId,
      messageId: widget.messageId,
      reason: _selectedReason!,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
    );

    widget.onReportSubmitted(report);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Report User',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this user?',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ...ReportReason.values.map((reason) => _buildReasonOption(reason)),
            const SizedBox(height: 16),
            Text(
              'Additional details (optional)',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Provide more context...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null ? _submitReport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedReason != null ? Colors.red : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Report', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildReasonOption(ReportReason reason) {
    final isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.red : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              SecurityService.getReportReasonText(reason),
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
