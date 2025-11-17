import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as path;

class AmbilVideo extends StatefulWidget {
  const AmbilVideo({super.key});

  @override
  State<AmbilVideo> createState() => _AmbilVideoState();
}

class _AmbilVideoState extends State<AmbilVideo> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  String? _savedPath;
  VideoPlayerController? _videoController;

  Future<void> _getVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) await _saveToGallery(video.path);
  }

  Future<void> _getVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) await _saveToGallery(video.path);
  }

  Future<void> _saveToGallery(String filePath) async {
    try {
      final File file = File(filePath);
      final String fileName = path.basename(file.path);

      Map result;

      result = await ImageGallerySaverPlus.saveFile(filePath, name: fileName);

      bool success = (result['isSuccess'] ?? false) == true;

      setState(() {
        _mediaFile = file;
        _savedPath = result['filePath']?.toString();
      });

      _initializeVideoPlayer(filePath);

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

  Future<void> _initializeVideoPlayer(String path) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Video')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _getVideoFromCamera,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video dari Kamera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _getVideoFromGallery,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Video dari Galeri'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_mediaFile != null)
                _videoController != null &&
                        _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            VideoProgressIndicator(_videoController!,
                                allowScrubbing: true),
                            IconButton(
                              icon: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40, 
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _videoController!.value.isPlaying
                                      ? _videoController!.pause()
                                      : _videoController!.play();
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
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
      ),
    );
  }
}
