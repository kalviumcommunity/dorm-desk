import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new note with error handling
  Future<void> addNote(String uid, String text) async {
    try {
      if (text.trim().isEmpty) {
        throw 'Note cannot be empty';
      }
      
      await _db.collection('notes').add({
        'uid': uid,
        'text': text.trim(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw 'Failed to add note: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while adding note';
    }
  }

  // Add a new document with validation and security
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      // Validate update data
      final validatedData = _validateDocumentData(collection, data);
      
      // Add metadata
      final documentWithMetadata = {
        ...validatedData,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'version': 1,
      };
      
      await _db.collection(collection).add(documentWithMetadata);
    } on FirebaseException catch (e) {
      throw 'Failed to add document: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while adding document';
    }
  }

  // Get real-time stream of notes for a user
  Stream<QuerySnapshot> getNotes(String uid) {
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get collection documents
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _db.collection(collection).get();
    } on FirebaseException catch (e) {
      throw 'Failed to get collection: ${e.message}';
    }
  }

  // Get collection stream
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _db.collection(collection).snapshots();
  }

  // Update an existing note
  Future<void> updateNote(String noteId, String newText) async {
    try {
      if (newText.trim().isEmpty) {
        throw 'Note cannot be empty';
      }
      
      await _db.collection('notes').doc(noteId).update({
        'text': newText.trim(),
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw 'Failed to update note: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while updating note';
    }
  }

  // Delete a note with error handling
  Future<void> deleteNote(String id) async {
    try {
      await _db.collection('notes').doc(id).delete();
    } on FirebaseException catch (e) {
      throw 'Failed to delete note: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while deleting note';
    }
  }

  // Get a single note by ID
  Future<DocumentSnapshot?> getNote(String noteId) async {
    try {
      return await _db.collection('notes').doc(noteId).get();
    } on FirebaseException catch (e) {
      throw 'Failed to get note: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while getting note';
    }
  }

  // Search notes by text content
  Stream<QuerySnapshot> searchNotes(String uid, String searchText) {
    if (searchText.trim().isEmpty) {
      return getNotes(uid);
    }
    
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .where('text', isGreaterThanOrEqualTo: searchText)
        .where('text', isLessThanOrEqualTo: '$searchText\uf8ff')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update a document with validation and security
  Future<void> updateDocumentSecure(String collection, String docId, Map<String, dynamic> data, {bool merge = false}) async {
    try {
      // Validate update data
      final validatedData = _validateDocumentData(collection, data);
      
      // Add update metadata
      final updateData = {
        ...validatedData,
        'updatedAt': Timestamp.now(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
        'version': FieldValue.increment(1),
      };
      
      if (merge) {
        await _db.collection(collection).doc(docId).set(updateData, SetOptions(merge: true));
      } else {
        await _db.collection(collection).doc(docId).update(updateData);
      }
    } on FirebaseException catch (e) {
      throw 'Failed to update document: ${e.message}';
    } catch (e) {
      throw 'Failed to update document: $e';
    }
  }

  // Delete a document with security checks
  Future<void> deleteDocumentSecure(String collection, String docId) async {
    try {
      // Check if user has permission to delete
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'User must be authenticated to delete documents';
      }
      
      // Get document to verify ownership
      final docSnapshot = await _db.collection(collection).doc(docId).get();
      if (!docSnapshot.exists) {
        throw 'Document does not exist';
      }
      
      final docData = docSnapshot.data() as Map<String, dynamic>?;
      
      // Verify user ownership (optional - implement based on your app's requirements)
      // if (docData?['createdBy'] != currentUser.uid) {
      //   throw 'You can only delete documents you created';
      // }
      
      await _db.collection(collection).doc(docId).delete();
      
      // Log the deletion for audit trail
      await _db.collection('audit_log').add({
        'action': 'delete',
        'collection': collection,
        'documentId': docId,
        'deletedBy': currentUser.uid,
        'deletedAt': Timestamp.now(),
        'reason': 'User initiated deletion',
      });
    } on FirebaseException catch (e) {
      throw 'Failed to delete document: ${e.message}';
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  // Batch write operations for atomic updates
  Future<void> batchWrite(List<WriteBatch> operations) async {
    try {
      final batch = _db.batch();
      
      for (final operation in operations) {
        operation();
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw 'Failed to execute batch write: ${e.message}';
    } catch (e) {
      throw 'Failed to execute batch write: $e';
    }
  }

  // Transaction for atomic operations
  Future<T> runTransaction<T>(
    String collection,
    String docId,
    T Function(Transaction) transactionFunction,
  ) async {
    try {
      final docRef = _db.collection(collection).doc(docId);
      
      return await _db.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw 'Document does not exist';
        }
        
        return await transactionFunction(transaction);
      });
    } on FirebaseException catch (e) {
      throw 'Failed to run transaction: ${e.message}';
    } catch (e) {
      throw 'Failed to run transaction: $e';
    }
  }

  // Validate document data before writing
  Map<String, dynamic> _validateDocumentData(String collection, Map<String, dynamic> data) {
    final validatedData = <String, dynamic>{};
    
    // Remove sensitive fields that shouldn't be stored
    final sensitiveFields = ['password', 'secret', 'token', 'apiKey'];
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Skip sensitive fields
      if (sensitiveFields.contains(key.toLowerCase())) {
        continue;
      }
      
      // Validate required fields based on collection
      if (_isRequiredField(collection, key) && (value == null || value.toString().trim().isEmpty)) {
        throw 'Field $key is required and cannot be empty';
      }
      
      // Validate email format
      if (key.toLowerCase() == 'email' && value != null) {
        final email = value.toString().trim();
        if (!_isValidEmail(email)) {
          throw 'Invalid email format';
        }
      }
      
      // Validate string length
      if (value is String && value.toString().length > 1000) {
        throw 'Field $key is too long (max 1000 characters)';
      }
      
      validatedData[key] = value;
    }
    
    return validatedData;
  }

  // Check if field is required for a collection
  bool _isRequiredField(String collection, String field) {
    final requiredFields = <String, Set<String>>{
      'users': {'name', 'email'},
      'notes': {'title', 'content'},
      'products': {'name', 'price', 'category'},
      'tasks': {'title', 'description', 'status'},
    };
    
    return requiredFields[collection]?.contains(field) ?? false;
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Sanitize text input to prevent script injection
  String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>'), '') // Remove script tags
        .replaceAll(RegExp(r'javascript:'), '') // Remove javascript: protocol
        .trim();
  }
}
