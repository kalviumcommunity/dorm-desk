import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilteredIssuesScreen extends StatefulWidget {
  const FilteredIssuesScreen({super.key});

  @override
  State<FilteredIssuesScreen> createState() =>
      _FilteredIssuesScreenState();
}

class _FilteredIssuesScreenState
    extends State<FilteredIssuesScreen> {

  String selectedStatus = "open";

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DormDesk - Filtered Issues"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // 🔹 STATUS FILTER DROPDOWN
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "open",
                  child: Text("Open Issues"),
                ),
                DropdownMenuItem(
                  value: "closed",
                  child: Text("Closed Issues"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),

          // 🔹 REAL-TIME QUERY WITH FILTER + ORDER + LIMIT
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('issues')
                  .where('status', isEqualTo: selectedStatus)
                  .orderBy('priority', descending: true)
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No matching issues found"),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final issue = docs[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(issue['title']),
                        subtitle: Text(
                          "Priority: ${issue['priority']} | Status: ${issue['status']}",
                        ),
                        trailing: const Icon(Icons.arrow_forward),
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