import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeIssuesScreen extends StatefulWidget {
  const RealtimeIssuesScreen({super.key});

  @override
  State<RealtimeIssuesScreen> createState() =>
      _RealtimeIssuesScreenState();
}

class _RealtimeIssuesScreenState
    extends State<RealtimeIssuesScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addIssue(String title) async {
    await _firestore.collection('issues').add({
      'title': title,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteIssue(String id) async {
    await _firestore.collection('issues').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DormDesk - Live Issues"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter issue title",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addIssue(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: const Text("Add"),
                )
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('issues')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No issues available"),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final issue = docs[index];
                    return ListTile(
                      title: Text(issue['title']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            deleteIssue(issue.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}