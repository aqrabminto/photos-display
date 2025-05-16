import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_pro/features/searchPage.dart';

import '../Repos/images.dart';
import '../models/collectionModel.dart';
import '../models/topicsmodel.dart';
import 'favourites.dart';
import 'imagedetails.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final ImageController imageController = Get.put(ImageController());
  final TextEditingController searchController = TextEditingController();

  void onSearch(BuildContext context) async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final results = await imageController.searchImages(query);
      Get.to(() => SearchResultsPage(images: results, title: 'Search: $query'));
    } catch (e) {
      Get.snackbar("Search Error", e.toString());
    }
  }

  void onTopicTap(String slug, String title) {
    imageController.loadTopic(slug, title); // loads into homepage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Center(child: Text("Un-Splash")),
        actions: [GestureDetector(
            onTap: (){
              Get.to(()=>FavoritesPage());
            },
            child: Icon(Icons.favorite_border_outlined))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            //  Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (_) => onSearch(context),
                    decoration: InputDecoration(
                      hintText: 'Search images...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onSearch(context),
                  child: const Text("Search"),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Topics-List",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            //  Topics List
            FutureBuilder<List<TopicsModel>>(
              future: imageController.fetchTopics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                final topics = snapshot.data!;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return GestureDetector(
                        onTap: () {
                          onTopicTap(topic.slug, topic.title);
                        },
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    topic.coverPhoto.urls.small,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Collection-list",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<CollectionModel>>(
              future: imageController.fetchCollections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                final collections = snapshot.data!;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return GestureDetector(
                        onTap: () {
                          imageController.loadCollection(collection.id, collection.title);
                        },
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    collection.coverPhoto.urls.small,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                collection.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 12),

            //  Image Grid
            Expanded(
              child: GetBuilder<ImageController>(
                builder: (_) {
                  if (imageController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (imageController.images.isEmpty) {
                    return const Center(child: Text('No images found.'));
                  }

                  return Column(
                    children: [
                      if (imageController.selectedTopic != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Topic: ${imageController.selectedTopic}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () => imageController.clearTopic(),
                                icon: const Icon(Icons.clear),
                                label: const Text("Clear"),
                              ),
                            ],
                          ),
                        ),

                      // 🔳 Image Grid
                      Expanded(
                        child: GetBuilder<ImageController>(
                          builder: (controller) {
                            final isFiltered =
                                controller.selectedTopic != null || controller.selectedCollection != null;

                            return GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isFiltered ? 4 : 5,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: controller.images.length,
                              itemBuilder: (context, index) {
                                final image = controller.images[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => ImageGalleryPage(
                                      images: controller.images,
                                      initialIndex: index,
                                    ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      image.urls.regular,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
