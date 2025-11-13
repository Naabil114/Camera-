import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class AmbilGambar extends StatefulWidget {
  const AmbilGambar({super.key});

  @override
  State<AmbilGambar> createState() => _AmbilGambarState();
}

class _AmbilGambarState extends State<AmbilGambar> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  String? _savedPath;

  // 🔹 Ambil gambar dari kamera
  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) await _saveToGallery(image.path, isVideo: false);
  }

  // 🔹 Ambil gambar dari galeri
  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _saveToGallery(image.path, isVideo: false);
  }

  // 🔹 Simpan ke Galeri menggunakan image_gallery_saver_plus
  Future<void> _saveToGallery(String filePath, {required bool isVideo}) async {
    try {
      final File file = File(filePath);
      Uint8List bytes = await file.readAsBytes();
      final String fileName = path.basename(file.path);

      Map result = await ImageGallerySaverPlus.saveImage(bytes, name: fileName);

      bool success = (result['isSuccess'] ?? false) == true;

      setState(() {
        _mediaFile = file;
        _savedPath = result['filePath']?.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '✅ Berhasil disimpan ke Galeri!'
              : '❌ Gagal menyimpan ke Galeri!'),
        ),
      );
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Gambar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _getImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto dari Kamera'),
                ),
                ElevatedButton.icon(
                  onPressed: _getImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Foto dari Galeri'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_mediaFile != null) Image.file(_mediaFile!, height: 200),
            if (_savedPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Disimpan di: $_savedPath',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
