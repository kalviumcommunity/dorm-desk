import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {

  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Login")),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: () async {

                final user = await auth.login(
                  emailController.text,
                  passwordController.text,
                );

                if (user != null) {

                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: user.uid,
                  );

                }

              },

              child: const Text("Login"),

            ),

            TextButton(

              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },

              child: const Text("Create Account"),

            ),

          ],

        ),

      ),

    );

  }

}