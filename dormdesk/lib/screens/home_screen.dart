import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen(this.uid, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController noteController;
  final firestore = FirestoreService();
  final auth = AuthService();

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(controller: noteController),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                firestore.addNote(widget.uid, noteController.text);
                noteController.clear();
              }
            },
            child: const Text('Add Note'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.getNotes(widget.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No notes yet'));
                }
                return ListView(
                  children: docs.map((d) {
                    return ListTile(
                      title: Text(d['text']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => firestore.deleteNote(d.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
