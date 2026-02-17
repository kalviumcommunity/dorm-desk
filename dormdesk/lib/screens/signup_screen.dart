import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatelessWidget {

  SignupScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('Sign Up')),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: () async {

                final user = await auth.signUp(
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

              child: const Text('Sign Up'),

            ),

            TextButton(

              onPressed: () {

                Navigator.pushNamed(context, '/login');

              },

              child: const Text('Already have account? Login'),

            )

          ],
        ),
      ),
    );
  }
}