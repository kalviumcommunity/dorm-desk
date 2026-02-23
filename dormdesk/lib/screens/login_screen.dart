import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final AuthService auth = AuthService();

  String error = "";

  @override
  void initState() {

    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();

  }

  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Login"),
      ),

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

                try {

                  await auth.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );

                } catch (e) {

                  setState(() {
                    error = e.toString();
                  });

                }

              },

              child: const Text("Login"),

            ),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),

            TextButton(

              onPressed: () {

                Navigator.pushNamed(context, '/signup');

              },

              child: const Text("Create Account"),

            )

          ],

        ),

      ),

    );

  }

}