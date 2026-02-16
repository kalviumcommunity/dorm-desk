import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

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
        .where('text', isLessThanOrEqualTo: searchText + '\uf8ff')
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
}
