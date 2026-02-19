import 'package:flutter/material.dart';

class ResponsiveDesignDemo extends StatelessWidget {
  const ResponsiveDesignDemo({super.key});

  @override
  Widget build(BuildContext context) {

    // MediaQuery gives screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Responsive Design Demo"),
        centerTitle: true,
      ),

      body: LayoutBuilder(

        builder: (context, constraints) {

          // LayoutBuilder gives layout constraints
          bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {

            // MOBILE LAYOUT
            return Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Container(

                  width: screenWidth * 0.8,
                  height: screenHeight * 0.15,

                  margin: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Center(
                    child: Text(
                      "Mobile Layout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),

                ),

                Container(

                  width: screenWidth * 0.8,
                  height: screenHeight * 0.15,

                  margin: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Center(
                    child: Text(
                      "DormDesk Mobile Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),

                ),

              ],

            );

          } else {

            // TABLET LAYOUT
            return Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                Container(

                  width: screenWidth * 0.3,
                  height: screenHeight * 0.3,

                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Center(
                    child: Text(
                      "Tablet Left Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),

                ),

                Container(

                  width: screenWidth * 0.3,
                  height: screenHeight * 0.3,

                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Center(
                    child: Text(
                      "Tablet Right Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),

                ),

              ],

            );

          }

        },

      ),

    );

  }

}