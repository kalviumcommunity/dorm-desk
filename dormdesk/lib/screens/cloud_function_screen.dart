import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionScreen extends StatefulWidget {
  const CloudFunctionScreen({super.key});

  @override
  State<CloudFunctionScreen> createState() =>
      _CloudFunctionScreenState();
}

class _CloudFunctionScreenState
    extends State<CloudFunctionScreen> {

  String responseMessage = "Press button to call Cloud Function";
  bool isLoading = false;

  Future<void> callFunction() async {
    setState(() {
      isLoading = true;
    });

    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('sayHello');

      final result = await callable.call({
        'name': 'Ram'
      });

      setState(() {
        responseMessage = result.data['message'];
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        responseMessage = "Error calling function";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Function Demo"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              if (isLoading)
                const CircularProgressIndicator(),

              const SizedBox(height: 20),

              Text(
                responseMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: callFunction,
                child: const Text("Call Cloud Function"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}