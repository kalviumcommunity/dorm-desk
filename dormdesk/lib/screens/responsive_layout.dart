import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {

  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    bool isTablet = width > 600;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Responsive Layout"),
      ),

      body: Container(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              width: double.infinity,
              height: 120,

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Center(
                child: Text(
                  "DormDesk Header",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),

            ),

            const SizedBox(height: 16),

            Expanded(

              child: isTablet

                  ? Row(

                      children: [

                        Expanded(
                          child: Container(
                            color: Colors.orange,
                            child: const Center(
                              child: Text("Left Panel"),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Container(
                            color: Colors.green,
                            child: const Center(
                              child: Text("Right Panel"),
                            ),
                          ),
                        ),

                      ],
                    )

                  : Column(

                      children: [

                        Expanded(
                          child: Container(
                            color: Colors.orange,
                            child: const Center(
                              child: Text("Top Panel"),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: Container(
                            color: Colors.green,
                            child: const Center(
                              child: Text("Bottom Panel"),
                            ),
                          ),
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