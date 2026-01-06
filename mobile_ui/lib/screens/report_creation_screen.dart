import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportCreationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  const ReportCreationScreen({super.key, required this.onBack, required this.onSubmit});

  @override
  State<ReportCreationScreen> createState() => _ReportCreationScreenState();
}

class _ReportCreationScreenState extends State<ReportCreationScreen> {
  final categories = ['Roads', 'Lighting', 'Waste', 'Water', 'Environment', 'Safety'];
  String selected = 'Roads';
  final _descCtrl = TextEditingController();
  final _svc = ReportService();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  double _latitude = 33.5731;
  double _longitude = -7.5898;

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a description')));
      return;
    }
    try {
      // Upload selected photos
      final urls = <String>[];
      print('Starting photo upload, ${_photos.length} photos selected');
      for (final x in _photos) {
        final bytes = await x.readAsBytes();
        final name = '${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg';
        final ref = FirebaseStorage.instance.ref().child('reports').child(name);
        print('Uploading $name to Storage...');
        final task = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        final url = await task.ref.getDownloadURL();
        print('Photo uploaded successfully: $url');
        urls.add(url);
      }
      print('All photos uploaded, URLs: $urls');
      await _svc.createReport(
        category: selected,
        description: desc,
        latitude: _latitude,
        longitude: _longitude,
        photoUrls: urls,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
      widget.onSubmit();
    } catch (e, stack) {
      print('Submit error: $e');
      print('Stack: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Report a Problem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photoPicker(),
            const SizedBox(height: 16),
            Text('Select Category *', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _categoryGrid(),
            const SizedBox(height: 16),
            Text('Description *', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _inputArea('Describe the problem in detail...'),
            const SizedBox(height: 12),
            _locationCard(),
            const SizedBox(height: 16),
            _tipsCard(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B8DEF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit Report'),
        ),
      ),
    );
  }

  Widget _photoPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, style: BorderStyle.solid, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, size: 40, color: Colors.blue.shade400),
              const SizedBox(width: 12),
              const Text('Add photos'),
              const Spacer(),
              TextButton(onPressed: _pickPhoto, child: const Text('Upload')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photos.map((x) => FutureBuilder<Uint8List>(
              future: x.readAsBytes(),
              builder: (ctx, snap) {
                if (snap.hasData) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.memory(snap.data!, fit: BoxFit.cover),
                  );
                }
                return const SizedBox(width: 80, height: 80, child: CircularProgressIndicator());
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await _picker.pickMultiImage();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _photos
          ..clear()
          ..addAll(result.take(3));
      });
    }
  }

  Widget _categoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final c = categories[i];
        final selectedCard = c == selected;
        return GestureDetector(
          onTap: () => setState(() => selected = c),
          child: Container(
            decoration: BoxDecoration(
              color: selectedCard ? const Color(0xFFEEF4FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selectedCard ? const Color(0xFF5B8DEF) : Colors.grey.shade200),
            ),
            child: Center(
              child: Text(c, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
            ),
          ),
        );
      },
    );
  }

  Widget _inputArea(String hint) {
    return TextField(
      controller: _descCtrl,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8),
              Text('Location'),
            ],
          ),
          const SizedBox(height: 8),
          Text('${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.map),
            label: const Text('Pick Location on Map'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<Map<String, double>>(
      MaterialPageRoute(
        builder: (context) => _LocationPickerScreen(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _latitude = result['lat']!;
        _longitude = result['lng']!;
      });
    }
  }

  Widget _tipsCard() {
    final tips = [
      'Include clear photos showing the problem',
      'Provide specific location details',
      'Describe the urgency if applicable',
      'Be respectful and constructive',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tips for a better report:', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.brightness_1, size: 8, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  const _LocationPickerScreen({required this.initialLat, required this.initialLng});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late double _lat;
  late double _lng;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'lat': _lat, 'lng': _lng}),
            child: const Text('Confirm', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_lat, _lng),
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  _lat = point.latitude;
                  _lng = point.longitude;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.houmetna.mobile_ui',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(_lat, _lng),
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tap on map to select location', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}', style: GoogleFonts.inter(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
