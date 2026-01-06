import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class MyReportsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String reportId) onReportTap;
  const MyReportsScreen({super.key, required this.onBack, required this.onReportTap});

  Stream<List<Report>> _stream() => ReportService().getUserReports();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('My Reports'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          _filterTabs(),
          Expanded(
            child: StreamBuilder<List<Report>>(
              stream: _stream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reports = snapshot.data ?? [];
                if (reports.isEmpty) {
                  return const Center(child: Text('No reports yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, i) => _reportCard(reports[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTabs() {
    final tabs = ['All', 'New', 'Active', 'Done'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: tabs
            .map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: t == 'All',
                    onSelected: (_) {},
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _reportCard(Report item) {
    return GestureDetector(
      onTap: () => onReportTap(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}', style: GoogleFonts.inter(color: Colors.black54))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${item.createdAt}', style: GoogleFonts.inter(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
            _statusChip(item.getStatusLabel(), item.getStatusColor()),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

// Removed static placeholder model; using real Report model.
