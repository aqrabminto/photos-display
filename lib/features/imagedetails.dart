// pages/image_gallery_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../Repos/images.dart';
import '../models/imagemodel.dart';

class ImageGalleryPage extends StatefulWidget {
  final List<ImageModel> images;
  final int initialIndex;

  const ImageGalleryPage(
      {super.key, required this.images, required this.initialIndex});

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  late PageController _controller;
  late int currentIndex;
  final ImageController imageController = Get.find(); // Access controller

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  Future<void> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final success = await GallerySaver.saveImage(file.path, toDcim: true);

      if (success == true) {
        Get.snackbar("Downloaded", "Image saved to gallery");
      } else {
        Get.snackbar("Error", "Save failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Download failed: $e");
    }
  }

  Future<void> _shareImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/shared_image.jpg').writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: "Check out this Unsplash image!");
    } catch (e) {
      Get.snackbar("Error", "Share failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Gallery"),
        actions: [
          IconButton(
            icon: Icon(
              imageController.isFavorite(widget.images[currentIndex])
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: () {
              setState(() {
                imageController.toggleFavorite(widget.images[currentIndex]);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _downloadImage(widget.images[currentIndex].urls.regular);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareImage(widget.images[currentIndex].urls.regular);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (_, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                image.urls.regular,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
