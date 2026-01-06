import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class MapViewScreen extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String reportId) onReportTap;
  const MapViewScreen({super.key, required this.onBack, required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Map View'),
      ),
      body: StreamBuilder<List<Report>>(
        stream: ReportService().getAllReports(),
        builder: (context, snapshot) {
          final reports = snapshot.data ?? [];
          final List<Marker> markers = reports.map<Marker>((r) => Marker(
                width: 40,
                height: 40,
                point: LatLng(r.latitude, r.longitude),
                child: GestureDetector(
                  onTap: () => onReportTap(r.id),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: r.status == 'resolved' ? Colors.green : (r.status == 'in-progress' ? Colors.blue : Colors.red),
                        size: 36,
                      ),
                    ],
                  ),
                ),
              )).toList();
          
          final center = reports.isNotEmpty 
              ? LatLng(reports.first.latitude, reports.first.longitude) 
              : const LatLng(33.5731, -7.5898);

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.houmetna.mobile_ui',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
