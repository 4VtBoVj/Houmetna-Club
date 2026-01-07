import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class MunicipalityDashboardScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReportTap;
  const MunicipalityDashboardScreen(
      {super.key, required this.onBack, required this.onReportTap});

  @override
  State<MunicipalityDashboardScreen> createState() =>
      _MunicipalityDashboardScreenState();
}

class _MunicipalityDashboardScreenState
    extends State<MunicipalityDashboardScreen> {
  final _reportService = ReportService();
  final _functions = FirebaseFunctions.instance;

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      final callable = _functions.httpsCallable('updateReportStatus');
      print(
          'Calling updateReportStatus with reportId: $reportId, status: $newStatus');
      await callable.call({
        'reportId': reportId,
        'status': newStatus,
      });
      print('✅ Status updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report status updated to $newStatus')),
      );
      setState(() {}); // Refresh the dashboard
    } catch (e) {
      print('❌ Error: $e');
      print('Error details: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Municipality Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statsSection(),
            const SizedBox(height: 16),
            Text('Pending Reports',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _reportsListSection(),
          ],
        ),
      ),
    );
  }

  Widget _statsSection() {
    return StreamBuilder<List<Report>>(
      stream: _reportService.getAllReports(),
      builder: (context, snapshot) {
        int open = 0;
        int inProgress = 0;
        int resolved = 0;
        int urgent = 0;

        if (snapshot.hasData) {
          final reports = snapshot.data!;
          open = reports.where((r) => r.status == 'new').length;
          inProgress = reports.where((r) => r.status == 'in-progress').length;
          resolved = reports.where((r) => r.status == 'resolved').length;
          urgent = reports.where((r) => r.category == 'Safety').length;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (_, i) {
            final cards = [
              _StatCard('Open', open.toString(), Colors.orange),
              _StatCard('In Progress', inProgress.toString(), Colors.blue),
              _StatCard('Resolved', resolved.toString(), Colors.green),
              _StatCard('Urgent', urgent.toString(), Colors.red),
            ];
            return _statCard(cards[i]);
          },
        );
      },
    );
  }

  Widget _reportsListSection() {
    return StreamBuilder<List<Report>>(
      stream: _reportService.getAllReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No reports available',
                style: GoogleFonts.inter(color: Colors.black54)),
          );
        }

        final reports =
            snapshot.data!.where((r) => r.status != 'resolved').toList();
        return Column(
          children:
              reports.map((report) => _reportRowWithStatus(report)).toList(),
        );
      },
    );
  }

  Widget _reportRowWithStatus(Report report) {
    final statusColor = {
          'new': Colors.blue,
          'in-progress': Colors.orange,
          'resolved': Colors.green,
        }[report.status] ??
        Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.description.length > 30
                          ? '${report.description.substring(0, 30)}...'
                          : report.description,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${report.category} • ${report.location}',
                      style: GoogleFonts.inter(
                          color: Colors.black54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _pill(report.status, statusColor),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (report.status == 'new')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.pending_actions, size: 16),
                        label:
                            const Text('Start', style: TextStyle(fontSize: 12)),
                        onPressed: () =>
                            _updateReportStatus(report.id, 'in-progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                  if (report.status != 'resolved')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.done_all, size: 16),
                      label:
                          const Text('Resolve', style: TextStyle(fontSize: 12)),
                      onPressed: () =>
                          _updateReportStatus(report.id, 'resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(_StatCard card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: card.color.withOpacity(0.15),
              child: Icon(Icons.bar_chart, color: card.color)),
          const Spacer(),
          Text(card.label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text(card.value,
              style:
                  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _StatCard {
  final String label;
  final String value;
  final Color color;
  _StatCard(this.label, this.value, this.color);
}
