import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;

class FirebaseStorageDemo extends StatefulWidget {
  const FirebaseStorageDemo({super.key});

  @override
  State<FirebaseStorageDemo> createState() => _FirebaseStorageDemoState();
}

class _FirebaseStorageDemoState extends State<FirebaseStorageDemo> {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<String> _uploadedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedImagePath;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadUploadedImages();
  }

  Future<void> _loadUploadedImages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('uploads')
          .orderBy('uploadedAt', descending: true)
          .get();

      setState(() {
        _uploadedImages = snapshot.docs
            .map((doc) => doc['downloadUrl'] as String)
            .toList();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading images: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          _selectedImagePath = file.path;
          _statusMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImagePath == null) {
      setState(() {
        _statusMessage = 'Please select an image first';
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _statusMessage = 'Please login to upload images';
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _statusMessage = 'Uploading...';
      });

      // Create unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg';
      final file = File(_selectedImagePath!);
      
      // Create storage reference
      final storageRef = _storage.ref().child('uploads/$fileName');

      // Start upload
      final uploadTask = storageRef.putFile(file);

      // Monitor upload progress
      uploadTask.asStream().listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload completion
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('uploads')
            .add({
              'fileName': fileName,
              'downloadUrl': downloadUrl,
              'uploadedAt': cf.Timestamp.now(),
              'fileSize': await file.length(),
              'contentType': 'image/jpeg',
            });

        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
          _statusMessage = 'Upload successful!';
          _uploadedImages.insert(0, downloadUrl);
          _selectedImagePath = null;
        });

        // Refresh the list
        await _loadUploadedImages();

      } else {
        throw Exception('Upload failed: ${snapshot.state}');
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Upload failed: $e';
      });
    }
  }

  Future<void> _deleteImage(String downloadUrl, int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get file reference from URL
      final ref = _storage.refFromURL(downloadUrl);
      
      // Delete from storage
      await ref.delete();

      // Remove from Firestore (find the document)
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('uploads')
          .where('downloadUrl', isEqualTo: downloadUrl)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _uploadedImages.removeAt(index);
        _statusMessage = 'Image deleted successfully';
      });

    } catch (e) {
      setState(() {
        _statusMessage = 'Error deleting image: $e';
      });
    }
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final XFile? file = await _imagePicker.pickMedia();
      
      if (file != null) {
        await _uploadDocument(file);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking document: $e';
      });
    }
  }

  Future<void> _uploadDocument(XFile file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _statusMessage = 'Please login to upload documents';
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _statusMessage = 'Uploading document...';
      });

      // Create unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}_${file.name}';
      final fileData = File(file.path);

      // Determine content type
      String contentType = 'application/octet-stream';
      if (file.name.toLowerCase().endsWith('.pdf')) {
        contentType = 'application/pdf';
      } else if (file.name.toLowerCase().endsWith('.doc') || file.name.toLowerCase().endsWith('.docx')) {
        contentType = 'application/msword';
      } else if (file.name.toLowerCase().endsWith('.txt')) {
        contentType = 'text/plain';
      }

      // Create storage reference
      final storageRef = _storage.ref().child('documents/$fileName');

      // Start upload
      final uploadTask = storageRef.putFile(fileData, SettableMetadata(contentType: contentType));

      // Monitor upload progress
      uploadTask.asStream().listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload completion
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('documents')
            .add({
              'fileName': file.name,
              'downloadUrl': downloadUrl,
              'uploadedAt': cf.Timestamp.now(),
              'fileSize': await fileData.length(),
              'contentType': contentType,
            });

        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
          _statusMessage = 'Document uploaded successfully!';
        });

      } else {
        throw Exception('Upload failed: ${snapshot.state}');
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Document upload failed: $e';
      });
    }
  }

  Widget _buildUploadSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Media to Firebase Storage',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Selected image preview
            if (_selectedImagePath != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Document upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickAndUploadDocument,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Upload button for selected image
            if (_selectedImagePath != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImage,
                  icon: _isUploading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Progress indicator
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedImagesGrid() {
    if (_uploadedImages.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No images uploaded yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Images',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _uploadedImages[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Delete button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _deleteImage(imageUrl, index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUploadedImages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status message
          if (_statusMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _statusMessage!.contains('Error') 
                  ? Colors.red.shade50 
                  : _statusMessage!.contains('successful')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains('Error')
                      ? Colors.red.shade700
                      : _statusMessage!.contains('successful')
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                  ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildUploadSection(),
                  const SizedBox(height: 16),
                  _buildUploadedImagesGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
