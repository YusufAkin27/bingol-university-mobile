import 'package:flutter/material.dart';

class ArchivesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arşivler'),
      ),
      body: ListView.builder(
        itemCount: 10, // Örnek veri sayısı
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.archive, color: Colors.grey),
              title: Text('Arşivlenmiş İçerik $index'),
              subtitle: Text('Bu içerik arşivlendi.'),
            ),
          );
        },
      ),
    );
  }
} 