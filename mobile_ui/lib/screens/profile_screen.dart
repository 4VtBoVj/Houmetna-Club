import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onBack, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final email = user?.email;
    String initials = _initials(displayName, email);
    final shownName = displayName?.isNotEmpty == true
        ? displayName!
        : (email != null ? _nameFromEmail(email) : 'Guest');
    final shownEmail = email ?? 'No email';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, backgroundColor: const Color(0xFF1F75FF), child: Text(initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28))),
            const SizedBox(height: 12),
            Text(shownName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(shownEmail, style: GoogleFonts.inter(color: Colors.black54)),
            const SizedBox(height: 16),
            _stats(),
            const SizedBox(height: 16),
            _section('Account Settings', [
              _tile(Icons.edit, 'Edit Profile', 'Update your personal information'),
              _tile(Icons.notifications, 'Notifications', 'Manage notification preferences'),
            ]),
            _section('App Settings', [
              _tile(Icons.language, 'Language', 'English'),
              _tile(Icons.lock, 'Privacy & Security', 'Control your data and privacy'),
            ]),
            _section('Language Selection', [
              _radioTile('English', true),
              _radioTile('العربية', false),
              _radioTile('Français', false),
            ]),
            _section('Support', [
              _tile(Icons.help_outline, 'Help Center', 'FAQs and support'),
            ]),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await AuthService().signOut();
                onLogout();
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 12),
            Text('HOUMETNA v1.0.0', style: GoogleFonts.inter(color: Colors.black45)),
          ],
        ),
      ),
    );
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

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _stats() {
    Widget badge(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(color: Colors.black54)),
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
          active = total - resolved;
        }
        return Row(
          children: [
            badge('Active', '$active'),
            const SizedBox(width: 8),
            badge('Resolved', '$resolved'),
            const SizedBox(width: 8),
            badge('My Reports', '$total'),
          ],
        );
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1F75FF)),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: Colors.black54, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _radioTile(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<bool>(value: true, groupValue: selected, onChanged: (_) {}),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.inter()),
        ],
      ),
    );
  }
}
