import 'package:flutter/material.dart';

class ScrollableViews extends StatelessWidget {

  const ScrollableViews({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Scrollable Views")),

      body: SingleChildScrollView(

        child: Column(

          children: [

            SizedBox(

              height: 200,

              child: ListView.builder(

                scrollDirection: Axis.horizontal,

                itemCount: 10,

                itemBuilder: (context, index) {

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Center(child: Text("Item $index")),
                  );

                },

              ),

            ),

            GridView.builder(

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),

              itemCount: 6,

              itemBuilder: (context, index) {

                return Container(
                  margin: const EdgeInsets.all(8),
                  color: Colors.green,
                  child: Center(child: Text("Tile $index")),
                );

              },

            ),

          ],

        ),

      ),

    );

  }

}