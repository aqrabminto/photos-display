import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Repos/images.dart';
import 'imagedetails.dart';

class FavoritesPage extends StatelessWidget {
  final ImageController imageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Favorites"))),
      body: GetBuilder<ImageController>(
        builder: (_) {
          if (_.favorites.isEmpty) {
            return const Center(child: Text("No favorite images yet."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _.favorites.length,
            itemBuilder: (context, index) {
              final image = _.favorites[index];
              return GestureDetector(
                onTap: (){
                  Get.to(() => ImageGalleryPage(
                    images: _.favorites,
                    initialIndex: index,
                  ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(image.urls.regular, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
