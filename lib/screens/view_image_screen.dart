import 'dart:io';
import 'package:flutter/material.dart';

class ViewImageScreen extends StatelessWidget {
  final String imagePath;

  ViewImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Image', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(File(imagePath), fit: BoxFit.contain)
            : Text('No Image Available'),
      ),
    );
  }
}
