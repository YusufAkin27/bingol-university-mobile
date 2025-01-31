import 'package:flutter/material.dart';

class MyCommentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yaptığım Yorumlar'),
      ),
      body: ListView.builder(
        itemCount: 10, // Örnek veri sayısı
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.comment, color: Colors.blue),
              title: Text('Yorum $index'),
              subtitle: Text('Bu yorumun içeriği burada.'),
            ),
          );
        },
      ),
    );
  }
} 