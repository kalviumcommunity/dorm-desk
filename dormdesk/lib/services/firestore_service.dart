import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> addNote(String uid, String text) async {
    await _db.collection('notes').add({
      'uid': uid,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotes(String uid) {
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}
