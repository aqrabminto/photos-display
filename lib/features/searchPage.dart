import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_pro/features/homepage.dart';

import '../models/imagemodel.dart';
import 'imagedetails.dart';

class SearchResultsPage extends StatelessWidget {
  final List<ImageModel> images;
  final String title;

  const SearchResultsPage({super.key, required this.images, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: GestureDetector(
        child: Icon(Icons.arrow_back),
        onTap: (){
          Get.to(()=>MyHomePage());
        },
      ),
          title: Center(child: Text('Search page'))),
      body: images.isEmpty
          ? const Center(child: Text("No images found"))
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => ImageGalleryPage(images: images, initialIndex: index));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image.urls.regular,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }
}
