import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filterStatus = 'All';
  String _filterReason = 'All';

  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'reporter': 'Sarah Johnson',
      'reported': 'SpamBot123',
      'reason': 'Spam',
      'description': 'Sending automated messages with links',
      'status': 'pending',
      'date': '2024-03-15 10:30 AM',
      'messageId': 'msg_123',
    },
    {
      'id': '2',
      'reporter': 'John Smith',
      'reported': 'TrollUser',
      'reason': 'Harassment',
      'description': 'Repeated offensive messages',
      'status': 'pending',
      'date': '2024-03-15 09:15 AM',
      'messageId': 'msg_456',
    },
    {
      'id': '3',
      'reporter': 'Emma Brown',
      'reported': 'BadActor',
      'reason': 'Inappropriate Content',
      'description': 'Sharing inappropriate images',
      'status': 'pending',
      'date': '2024-03-14 08:45 PM',
      'messageId': 'msg_789',
    },
    {
      'id': '4',
      'reporter': 'Ahmed Hassan',
      'reported': 'FakeUser',
      'reason': 'Spam',
      'description': 'Fake account promoting products',
      'status': 'reviewed',
      'date': '2024-03-14 03:20 PM',
      'messageId': 'msg_101',
      'action': 'Account suspended',
    },
    {
      'id': '5',
      'reporter': 'Maria Garcia',
      'reported': 'OffensiveUser',
      'reason': 'Harassment',
      'description': 'Bullying other users',
      'status': 'resolved',
      'date': '2024-03-13 11:00 AM',
      'messageId': 'msg_202',
      'action': 'User banned',
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    return _reports.where((report) {
      final matchesStatus = _filterStatus == 'All' ||
          report['status'] == _filterStatus.toLowerCase();
      final matchesReason = _filterReason == 'All' ||
          report['reason'] == _filterReason;
      return matchesStatus && matchesReason;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports Management',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  // Status filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      items: ['All', 'Pending', 'Reviewed', 'Resolved']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => _filterStatus = value!),
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reason filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButton<String>(
                      value: _filterReason,
                      items: ['All', 'Spam', 'Harassment', 'Inappropriate Content', 'Other']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => _filterReason = value!),
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              _buildReportStat('Pending', '3', Icons.pending, Colors.orange),
              const SizedBox(width: 16),
              _buildReportStat('Reviewed', '1', Icons.visibility, Colors.blue),
              const SizedBox(width: 16),
              _buildReportStat('Resolved', '1', Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildReportStat('Total', '5', Icons.flag, const Color(0xFF6C63FF)),
            ],
          ),
          const SizedBox(height: 24),
          // Reports list
          ..._filteredReports.map((report) => _buildReportCard(report)),
        ],
      ),
    );
  }

  Widget _buildReportStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final statusColor = _getStatusColor(report['status']);
    final reasonColor = _getReasonColor(report['reason']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Reporter
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.white54),
                    const SizedBox(width: 8),
                    Text(
                      'Reported by ${report['reporter']}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report['status'].toString().toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Reported user
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Against: ${report['reported']}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: reasonColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report['reason'],
                  style: TextStyle(
                    color: reasonColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              report['description'],
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Date
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.white38),
              const SizedBox(width: 8),
              Text(
                report['date'],
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (report['action'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Action: ${report['action']}',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          if (report['status'] == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewMessage(report),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('View Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reviewReport(report),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Mark Reviewed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takeAction(report),
                    icon: const Icon(Icons.gavel, size: 18),
                    label: const Text('Take Action'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.white54;
    }
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'Spam':
        return Colors.orange;
      case 'Harassment':
        return Colors.red;
      case 'Inappropriate Content':
        return Colors.purple;
      default:
        return Colors.white54;
    }
  }

  void _viewMessage(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Reported Message',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message ID: ${report['messageId']}',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This is a placeholder for the actual reported message content.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _reviewReport(Map<String, dynamic> report) {
    setState(() {
      report['status'] = 'reviewed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report marked as reviewed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _takeAction(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Take Action',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What action should be taken against ${report['reported']}?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildActionOption('Warning', Icons.warning, Colors.orange, report),
            const SizedBox(height: 8),
            _buildActionOption('Suspend Account', Icons.block, Colors.red, report),
            const SizedBox(height: 8),
            _buildActionOption('Ban User', Icons.gavel, Colors.deepOrange, report),
            const SizedBox(height: 8),
            _buildActionOption('Dismiss Report', Icons.check, Colors.green, report),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption(String label, IconData icon, Color color, Map<String, dynamic> report) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          report['status'] = 'resolved';
          report['action'] = label;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label applied to user'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
