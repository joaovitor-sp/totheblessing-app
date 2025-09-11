import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class PostModel {
  final String? id;
  final String title;
  final String? content;
  final String? imageUrl;
  final XFile? imageFile;
  final DateTime activityDate;
  final String authorId;

  PostModel({
    this.id, 
    required this.title, 
    this.content,
    this.imageUrl,
    this.imageFile,
    required this.activityDate,
    required this.authorId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        imageUrl: json['imageUrl'],
        activityDate: DateTime.parse(json['activityDate']),
        authorId: json['authorId'],
      );
    
  Future<Map<String, dynamic>> toJson() async {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (content != null) 'content': content,
      if (imageFile != null) 'imageFile': await MultipartFile.fromFile(imageFile!.path),
      'activityDate': activityDate.toUtc().toIso8601String(),
      'authorId': authorId,
    };
  }
}
