import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {

  final String uid;

  HomeScreen(this.uid, {super.key});

  final noteController = TextEditingController();
  final firestore = FirestoreService();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Dashboard"),

        actions: [

          IconButton(

            icon: const Icon(Icons.logout),

            onPressed: () async {

              await auth.logout();
            },

          )

        ],

      ),

      body: Column(

        children: [

          TextField(controller: noteController),

          ElevatedButton(
            },

            child: const Text("Add Note"),

          ),


        ],

      ),

    );

  }

}