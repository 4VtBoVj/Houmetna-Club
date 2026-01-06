import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MunicipalityDashboardScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onReportTap;
  const MunicipalityDashboardScreen({super.key, required this.onBack, required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard('Open', '18', Colors.orange),
      _StatCard('In Progress', '9', Colors.blue),
      _StatCard('Resolved', '42', Colors.green),
      _StatCard('Urgent', '3', Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Municipality Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) => _statCard(cards[i]),
            ),
            const SizedBox(height: 16),
            Text('Recent Reports', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...List.generate(3, (i) => _reportRow()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(_StatCard card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundColor: card.color.withOpacity(0.15), child: Icon(Icons.bar_chart, color: card.color)),
          const Spacer(),
          Text(card.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text(card.value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _reportRow() {
    return GestureDetector(
      onTap: onReportTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            const Icon(Icons.report, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Street light out near park', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  Text('2 hours ago • Lighting', style: GoogleFonts.inter(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            _pill('New', Colors.blue),
          ],
        ),
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
      child: Text(text, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _StatCard {
  final String label;
  final String value;
  final Color color;
  _StatCard(this.label, this.value, this.color);
}
