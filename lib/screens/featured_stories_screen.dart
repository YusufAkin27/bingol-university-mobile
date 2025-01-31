import 'package:flutter/material.dart';

class FeaturedStoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öne Çıkarılan Hikayeler'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: 10, // Örnek veri sayısı
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blueAccent,
                    child: Center(child: Text('Hikaye $index')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Öne çıkarılan hikaye açıklaması.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 