import 'package:flutter/material.dart';

class CreateStoryScreen extends StatelessWidget {
  final TextEditingController _storyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hikaye Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storyController,
              decoration: InputDecoration(
                labelText: 'Hikaye İçeriği',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Hikaye gönderme işlemi
              },
              child: Text('Paylaş'),
            ),
          ],
        ),
      ),
    );
  }
} 