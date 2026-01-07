import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';
import '../models/report.dart';

class HomeScreen extends StatelessWidget {
  final void Function(AppScreen) onNavigate;
  final void Function(String reportId) onReportDetails;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onReportDetails,
    this.userRole = 'user',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 16),
              _statsRow(),
              const SizedBox(height: 12),
              _actionBar(context),
              const SizedBox(height: 12),
              _quickTiles(context),
              const SizedBox(height: 16),
              _categoryGrid(),
              const SizedBox(height: 16),
              _recentActivity(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _header() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final email = user?.email;
    final name = displayName?.isNotEmpty == true
        ? displayName!
        : (email != null ? _nameFromEmail(email) : 'Guest');
    final initials = _initials(displayName, email);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $name',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Let's make our city better",
                style: GoogleFonts.inter(color: Colors.black54)),
          ],
        ),
        const Spacer(),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF1F75FF),
          child: Text(initials,
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _statsRow() {
    Widget card(String title, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(value,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Report>>(
      stream: ReportService().getUserReports(),
      builder: (context, snapshot) {
        int total = 0;
        int resolved = 0;
        int active = 0;
        if (snapshot.hasData) {
          final reports = snapshot.data!;
          total = reports.length;
          resolved = reports.where((r) => r.status == 'resolved').length;
          active = total - resolved; // 'new' + 'in-progress'
        }
        return Row(
          children: [
            card('Active Reports', '$active', const Color(0xFF1F75FF)),
            const SizedBox(width: 10),
            card('Resolved', '$resolved', const Color(0xFF4CAF50)),
            const SizedBox(width: 10),
            card('My Reports', '$total', const Color(0xFF6C63FF)),
          ],
        );
      },
    );
  }

  Widget _actionBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12C064),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onNavigate(AppScreen.reportCreation),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Report a Problem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTiles(BuildContext context) {
    Widget tile(String title, IconData icon, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF1F75FF)),
                const SizedBox(height: 8),
                Text(title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile('My Reports', Icons.list_alt,
            () => onNavigate(AppScreen.myReports)),
        const SizedBox(width: 12),
        tile('Map View', Icons.map, () => onNavigate(AppScreen.map)),
        if (userRole == 'admin') ...[
          const SizedBox(width: 12),
          tile('Dashboard', Icons.admin_panel_settings,
              () => onNavigate(AppScreen.municipality)),
        ]
      ],
    );
  }

  Widget _categoryGrid() {
    final cats = [
      ('Roads', Icons.directions_car, Colors.orange.shade400),
      ('Lighting', Icons.lightbulb, Colors.amber.shade600),
      ('Waste', Icons.delete, Colors.green.shade600),
      ('Water', Icons.water_drop, Colors.blue.shade500),
      ('Environment', Icons.park, Colors.teal.shade600),
      ('Safety', Icons.warning, Colors.red.shade500),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final c = cats[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  backgroundColor: c.$3.withOpacity(0.15),
                  child: Icon(c.$2, color: c.$3)),
              const SizedBox(height: 8),
              Text(c.$1, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  Widget _recentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity',
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StreamBuilder<List<Report>>(
          stream: ReportService().getUserReports(),
          builder: (context, snapshot) {
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return const Text('No recent activity');
            }
            return Column(
              children: reports.take(5).map((r) {
                final msg = 'Report ${r.getStatusLabel()} — ${r.category}';
                return GestureDetector(
                  onTap: () => onReportDetails(r.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications,
                            color: Color(0xFF1F75FF)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${r.createdAt}',
                                  style: GoogleFonts.inter(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1F75FF),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        switch (i) {
          case 0:
            onNavigate(AppScreen.home);
            break;
          case 1:
            onNavigate(AppScreen.myReports);
            break;
          case 2:
            onNavigate(AppScreen.reportCreation);
            break;
          case 3:
            onNavigate(AppScreen.notifications);
            break;
          case 4:
            onNavigate(AppScreen.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Reports'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32), label: 'Add'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

String _initials(String? name, String? email) {
  if (name != null && name.trim().isNotEmpty) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
  if (email != null && email.isNotEmpty) {
    final local = email.split('@').first;
    final segs = local.split(RegExp(r"[._-]+"));
    if (segs.length >= 2) {
      return (segs.first[0] + segs[1][0]).toUpperCase();
    }
    return local.substring(0, local.length >= 2 ? 2 : 1).toUpperCase();
  }
  return 'U';
}

String _nameFromEmail(String email) {
  final local = email.split('@').first;
  final segs = local.split(RegExp(r"[._-]+"));
  if (segs.length >= 2) {
    return '${_capitalize(segs.first)} ${_capitalize(segs[1])}';
  }
  return _capitalize(segs.first);
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
