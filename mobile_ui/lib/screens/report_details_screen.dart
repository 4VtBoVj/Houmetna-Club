import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class ReportDetailsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String? reportId;
  const ReportDetailsScreen({super.key, required this.onBack, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Report Details'),
      ),
      body: reportId == null
          ? const Center(child: Text('No report selected'))
          : FutureBuilder<Report?>(
              future: ReportService().getReport(reportId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final report = snapshot.data;
                if (report == null) {
                  return const Center(child: Text('Report not found'));
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroImage(report.photoUrls),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _chip(report.getStatusLabel(), report.getStatusColor()),
                            const SizedBox(height: 10),
                            Text(report.category, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(report.description, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            _locationRow(report.latitude, report.longitude),
                            const SizedBox(height: 12),
                            Text('Description', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(report.description, style: GoogleFonts.inter(height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _heroImage(List<String> photos) {
    if (photos.isNotEmpty) {
      return SizedBox(
        height: 220,
        child: PageView(
          children: photos.map((url) => Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              print('Image load error: $error');
              print('URL: $url');
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              );
            },
          )).toList(),
        ),
      );
    }
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F75FF), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Icon(Icons.photo, color: Colors.white, size: 56)),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _locationRow(double lat, double lng) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Text('${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', style: GoogleFonts.inter(color: Colors.black54)),
            ],
          ),
        )
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _timelineItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.blue),
              SizedBox(height: 12),
              Icon(Icons.more_vert, size: 16, color: Colors.black26),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text(date, style: GoogleFonts.inter(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comment(String name, String text, String time, int likes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: Colors.grey.shade200, child: Text(name.characters.first)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(time, style: GoogleFonts.inter(color: Colors.black54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(text, style: GoogleFonts.inter()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(likes.toString()),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
