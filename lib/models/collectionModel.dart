import 'imagemodel.dart';

class CollectionModel {
  final String id;
  final String title;
  final ImageModel coverPhoto;

  CollectionModel({
    required this.id,
    required this.title,
    required this.coverPhoto,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      title: json['title'],
      coverPhoto: ImageModel.fromJson(json['cover_photo']),
    );
  }
}
