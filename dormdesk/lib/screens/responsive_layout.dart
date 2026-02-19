import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {

  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    bool isTablet = width > 600;

    return Scaffold(

      appBar: AppBar(title: const Text("Responsive Layout")),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(
              height: 120,
              color: Colors.blue,
              child: const Center(child: Text("Header")),
            ),

            const SizedBox(height: 10),

            Expanded(

              child: isTablet

                  ? Row(

                      children: [

                        Expanded(
                          child: Container(color: Colors.orange),
                        ),

                        Expanded(
                          child: Container(color: Colors.green),
                        ),

                      ],

                    )

                  : Column(

                      children: [

                        Expanded(
                          child: Container(color: Colors.orange),
                        ),

                        Expanded(
                          child: Container(color: Colors.green),
                        ),

                      ],

                    ),

            ),

          ],

        ),

      ),

    );

  }

}