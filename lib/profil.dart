import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _videoFile;
  VideoPlayerController? _videoController;
  String? _imagePathText;
  String? _videoPathText;

  static const String _keyImageInternal = 'profile_image_internal_path';
  static const String _keyImageGallery = 'profile_image_gallery_path';
  static const String _keyVideoInternal = 'profile_video_internal_path';
  static const String _keyVideoGallery = 'profile_video_gallery_path';

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final imgInternal = prefs.getString(_keyImageInternal);
    final imgGallery = prefs.getString(_keyImageGallery);
    final vidInternal = prefs.getString(_keyVideoInternal);
    final vidGallery = prefs.getString(_keyVideoGallery);

    File? imgFile;
    File? vidFile;

    if (imgInternal != null && imgInternal.isNotEmpty) {
      final f = File(imgInternal);
      if (f.existsSync()) {
        imgFile = f;
      }
    }

    if (vidInternal != null && vidInternal.isNotEmpty) {
      final f = File(vidInternal);
      if (f.existsSync()) {
        vidFile = f;
        await _initializeVideoPlayer(vidInternal);
      }
    }

    setState(() {
      _imageFile = imgFile;
      _videoFile = vidFile;
      _imagePathText = imgGallery;
      _videoPathText = vidGallery;
    });
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _saveImage(image.path);
    }
  }

  Future<void> _saveImage(String filePath) async {
    try {
      final file = File(filePath);
      Uint8List bytes = await file.readAsBytes();
      final fileName = path.basename(file.path);

      Map result = await ImageGallerySaverPlus.saveImage(bytes, name: fileName);
      bool success = (result['isSuccess'] ?? false) == true;
      final galleryPath = result['filePath']?.toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyImageInternal, file.path);
      if (galleryPath != null && galleryPath.isNotEmpty) {
        await prefs.setString(_keyImageGallery, galleryPath);
      }

      setState(() {
        _imageFile = file;
        _imagePathText = galleryPath ?? file.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '✅ Berhasil disimpan ke Galeri!'
              : '❌ Gagal menyimpan ke Galeri!'),
        ),
      );
    } catch (e) {
      debugPrint('Error saving image: $e');
    }
  }

  Future<void> _getVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      await _saveVideo(video.path);
    }
  }

  Future<void> _saveVideo(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = path.basename(file.path);

      Map result =
          await ImageGallerySaverPlus.saveFile(filePath, name: fileName);
      bool success = (result['isSuccess'] ?? false) == true;
      final galleryPath = result['filePath']?.toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyVideoInternal, file.path);
      if (galleryPath != null && galleryPath.isNotEmpty) {
        await prefs.setString(_keyVideoGallery, galleryPath);
      }

      await _initializeVideoPlayer(file.path);

      setState(() {
        _videoFile = file;
        _videoPathText = galleryPath ?? file.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '✅ Berhasil disimpan ke Galeri!'
              : '❌ Gagal menyimpan ke Galeri!'),
        ),
      );
    } catch (e) {
      debugPrint('Error saving video: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String pathValue) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(pathValue));
    await _videoController!.initialize();
    setState(() {});
    _videoController!.play();
  }

  Widget _buildVideoPreview() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_videoController!),
            VideoProgressIndicator(_videoController!, allowScrubbing: true),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.videocam,
          size: 64,
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Gambar'),
              ),
              if (_imagePathText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Disimpan di: $_imagePathText',
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              _buildVideoPreview(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getVideoFromCamera,
                icon: const Icon(Icons.videocam),
                label: const Text('Ambil Video'),
              ),
              if (_videoPathText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Disimpan di: $_videoPathText',
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
