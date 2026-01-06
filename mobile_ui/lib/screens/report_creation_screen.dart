import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a description')));
      return;
    }
    try {
      // Upload selected photos
      final urls = <String>[];
      for (final x in _photos) {
        final bytes = await x.readAsBytes();
        final name = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance.ref().child('reports').child(name);
        final task = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        final url = await task.ref.getDownloadURL();
        urls.add(url);
      }
      await _svc.createReport(
        category: selected,
        description: desc,
        latitude: 33.5731,
        longitude: -7.5898,
        photoUrls: urls,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
      widget.onSubmit();
    } catch (e) {
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
            children: _photos.map((x) => SizedBox(
              width: 80,
              height: 80,
              child: Image.network(x.path, fit: BoxFit.cover),
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
              Text('Current Location'),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Rue Mohammed V, Casablanca'),
          const Text('33.5731° N, 7.5898° W', style: TextStyle(color: Colors.black54)),
          TextButton(onPressed: () {}, child: const Text('Change Location')),
          const SizedBox(height: 6),
          const Text('Location is automatically detected using GPS', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
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
