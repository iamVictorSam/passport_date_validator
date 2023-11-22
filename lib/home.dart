import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passport_date_validator/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageHelper _imageHelper = ImageHelper();

  var selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedImage != null
                ? Image.file(selectedImage)
                : const Placeholder(),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  var image = await _imageHelper.pickImage();
                  setState(() {
                    selectedImage = File(image.path);
                  });
                },
                child: const Text('Select Image'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
