import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/api/endpoints.dart';
import '../models/collectionModel.dart';
import '../models/imagemodel.dart';
import '../models/topicsmodel.dart';

class ImageController extends GetxController {
  List<ImageModel> images = [];
  List<ImageModel> favorites = [];
  bool isLoading = true;
  String? selectedTopic;
  String? selectedCollection;

  @override
  void onInit() {
    fetchImages(); // Load default random images
    super.onInit();
  }
// Add to favorites
  void addToFavorites(ImageModel image) {
    if (!favorites.contains(image)) {
      favorites.add(image);
      update();
      Get.snackbar("Favorite", "Image added to favorites");
    }
  }

  // Remove from favorites
  void removeFromFavorites(ImageModel image) {
    favorites.remove(image);
    update();
    Get.snackbar("Favorite", "Image removed from favorites");
  }

  // Toggle favorite
  void toggleFavorite(ImageModel image) {
    if (favorites.contains(image)) {
      removeFromFavorites(image);
    } else {
      addToFavorites(image);
    }
  }

  bool isFavorite(ImageModel image) {
    return favorites.contains(image);
  }

  Future<String> getKey() async {
    return Endpoints.unsplashApiClientID;
  }

  /// Load random images
  Future<void> fetchImages() async {
    isLoading = true;
    selectedTopic = null; // Clear topic
    update();

    try {
      String apiKey = await getKey();
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos/random/?client_id=$apiKey&count=30'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);
        images = result.map((e) => ImageModel.fromJson(e)).toList();
      } else {
        Get.snackbar("Error", "Can't get images");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    isLoading = false;
    update();
  }

  ///  Search for images
  Future<List<ImageModel>> searchImages(String query) async {
    isLoading = true;
    update();

    try {
      String apiKey = await getKey();
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/search/photos?client_id=$apiKey&query=$query&per_page=30'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> results = json['results'];
        return results.map((e) => ImageModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search images');
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  ///  Load topic list
  Future<List<TopicsModel>> fetchTopics() async {
    String apiKey = await getKey();
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/topics?client_id=$apiKey&per_page=30'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TopicsModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load topics");
    }
  }

  Future<void> loadCollection(String collectionId, String title) async {
    isLoading = true;
    selectedTopic = null; // clear topic if any
    selectedCollection = title;
    update();

    try {
      String apiKey = await getKey();
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/collections/$collectionId/photos?client_id=$apiKey&per_page=30'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);
        images = result.map((e) => ImageModel.fromJson(e)).toList();
      } else {
        throw Exception("Can't load collection: $title");
      }
    } catch (e) {
      Get.snackbar("Collection Error", e.toString());
    }

    isLoading = false;
    update();
  }

  ///  Load images by topic into homepage
  Future<void> loadTopic(String slug, String title) async {
    isLoading = true;
    selectedTopic = title; // Show topic title in UI
    update();

    try {
      String apiKey = await getKey();
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/topics/$slug/photos?client_id=$apiKey&per_page=30&page=1'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);
        images = result.map((e) => ImageModel.fromJson(e)).toList();
      } else {
        throw Exception("Can't load topic: $title");
      }
    } catch (e) {
      Get.snackbar("Topic Error", e.toString());
    }

    isLoading = false;
    update();
  }

  Future<List<CollectionModel>> fetchCollections() async {
    String apiKey = await getKey();
    final response = await http.get(Uri.parse(
      'https://api.unsplash.com/collections?client_id=$apiKey&per_page=20',
    ));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CollectionModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load collections");
    }
  }

  Future<List<ImageModel>> getCollectionImages(String collectionId) async {
    String apiKey = await getKey();
    final response = await http.get(Uri.parse(
      'https://api.unsplash.com/collections/$collectionId/photos?client_id=$apiKey&per_page=30',
    ));

    if (response.statusCode == 200) {
      List<dynamic> result = jsonDecode(response.body);
      return result.map((e) => ImageModel.fromJson(e)).toList();
    } else {
      throw Exception("Can't load collection images");
    }
  }


  ///  Clear selected topic and reload random images
  void clearTopic() {
    fetchImages(); // Reset to random/default images
  }
}
