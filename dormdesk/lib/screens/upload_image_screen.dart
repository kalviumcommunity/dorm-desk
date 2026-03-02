import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() =>
      _UploadImageScreenState();
}

class _UploadImageScreenState
    extends State<UploadImageScreen> {

  File? _selectedImage;
  String? _downloadUrl;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child("uploads/$fileName.jpg");

      await storageRef.putFile(_selectedImage!);

      final downloadUrl =
          await storageRef.getDownloadURL();

      // Store URL in Firestore
      await FirebaseFirestore.instance
          .collection('media')
          .add({
        'imageUrl': downloadUrl,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _downloadUrl = downloadUrl;
        _isUploading = false;
      });

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Media - DormDesk"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: uploadImage,
              child: const Text("Upload to Firebase"),
            ),

            const SizedBox(height: 20),

            if (_isUploading)
              const CircularProgressIndicator(),

            const SizedBox(height: 20),

            if (_downloadUrl != null)
              Column(
                children: [
                  const Text("Uploaded Image:"),
                  const SizedBox(height: 10),
                  Image.network(
                    _downloadUrl!,
                    height: 200,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}