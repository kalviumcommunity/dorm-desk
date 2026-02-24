import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Get real-time stream of notes for a user
  Stream<QuerySnapshot> getNotes(String uid) {
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  // Get notes count for a user
  Future<int> getNotesCount(String uid) async {
    try {
      final snapshot = await _db
          .collection('notes')
          .where('uid', isEqualTo: uid)
          .count()
          .get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw 'Failed to get notes count: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while getting notes count';
    }
  }

  // Read a single document (general purpose)
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _db.collection(collection).doc(docId).get();
    } on FirebaseException catch (e) {
      throw 'Failed to read document: ${e.message}';
    } catch (e) {
      throw 'Failed to read document: $e';
    }
  }

  // Read all documents from a collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _db.collection(collection).get();
    } on FirebaseException catch (e) {
      throw 'Failed to read collection: ${e.message}';
    } catch (e) {
      throw 'Failed to read collection: $e';
    }
  }

  // Real-time stream for collection
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    try {
      return _db.collection(collection).snapshots();
    } on FirebaseException catch (e) {
      throw 'Failed to create stream: ${e.message}';
    } catch (e) {
      throw 'Failed to create stream: $e';
    }
  }

  // Real-time stream for single document
  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    try {
      return _db.collection(collection).doc(docId).snapshots();
    } on FirebaseException catch (e) {
      throw 'Failed to create document stream: ${e.message}';
    } catch (e) {
      throw 'Failed to create document stream: $e';
    }
  }

  // Query with filters
  Future<QuerySnapshot> queryCollection(
    String collection,
    String field,
    dynamic value, {
    String? operator,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _db.collection(collection);
      
      if (operator != null) {
        switch (operator) {
          case 'isEqualTo':
            query = query.where(field, isEqualTo: value);
            break;
          case 'isGreaterThan':
            query = query.where(field, isGreaterThan: value);
            break;
          case 'isLessThan':
            query = query.where(field, isLessThan: value);
            break;
          case 'arrayContains':
            query = query.where(field, arrayContains: value);
            break;
          case 'isGreaterThanOrEqualTo':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          case 'isLessThanOrEqualTo':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          default:
            query = query.where(field, isEqualTo: value);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } on FirebaseException catch (e) {
      throw 'Failed to query collection: ${e.message}';
    } catch (e) {
      throw 'Failed to query collection: $e';
    }
  }

  // Real-time query with filters
  Stream<QuerySnapshot> queryCollectionStream(
    String collection,
    String field,
    dynamic value, {
    String? operator,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query query = _db.collection(collection);
      
      if (operator != null) {
        switch (operator) {
          case 'isEqualTo':
            query = query.where(field, isEqualTo: value);
            break;
          case 'isGreaterThan':
            query = query.where(field, isGreaterThan: value);
            break;
          case 'isLessThan':
            query = query.where(field, isLessThan: value);
            break;
          case 'arrayContains':
            query = query.where(field, arrayContains: value);
            break;
          case 'isGreaterThanOrEqualTo':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          case 'isLessThanOrEqualTo':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          default:
            query = query.where(field, isEqualTo: value);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } on FirebaseException catch (e) {
      throw 'Failed to create query stream: ${e.message}';
    } catch (e) {
      throw 'Failed to create query stream: $e';
    }
  }

  // Check if document exists
  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw 'Failed to check document existence: ${e.message}';
    } catch (e) {
      throw 'Failed to check document existence: $e';
    }
  }

  // Get document data safely
  Map<String, dynamic>? getDocumentData(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>?;
  }

  // Get field value safely
  T? getFieldValue<T>(Map<String, dynamic>? data, String field) {
    if (data == null || !data.containsKey(field)) return null;
    return data[field] as T?;
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      return await _db.collection(collection).add(data);
    } on FirebaseException catch (e) {
      throw 'Failed to add document: ${e.message}';
    } catch (e) {
      throw 'Failed to add document: $e';
    }
  }

  // Get multiple documents by IDs
  Future<List<DocumentSnapshot>> getDocuments(String collection, List<String> docIds) async {
    try {
      final futures = docIds.map((id) => _db.collection(collection).doc(id).get()).toList();
      return await Future.wait(futures);
    } on FirebaseException catch (e) {
      throw 'Failed to get multiple documents: ${e.message}';
    } catch (e) {
      throw 'Failed to get multiple documents: $e';
    }
  }

  // Get collection with pagination
  Future<QuerySnapshot> getCollectionPaginated(
    String collection, {
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _db.collection(collection).limit(limit);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      return await query.get();
    } on FirebaseException catch (e) {
      throw 'Failed to get paginated collection: ${e.message}';
    } catch (e) {
      throw 'Failed to get paginated collection: $e';
    }
  }
}
