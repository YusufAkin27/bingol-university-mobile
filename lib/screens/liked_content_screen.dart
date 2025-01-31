import 'package:flutter/material.dart';

class LikedContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beğendiğim İçerikler'),
      ),
      body: ListView.builder(
        itemCount: 10, // Örnek veri sayısı
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('İçerik $index'),
              subtitle: Text('Bu içeriği beğendiniz.'),
            ),
          );
        },
      ),
    );
  }
} 