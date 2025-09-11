import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class GroupModel {
  final String? id;
  final String name;
  final String title;
  final String? content;
  final String? imageUrl;
  final XFile? imageFile;
  final DateTime? createdAt;
  final List<String> members;

  GroupModel({
    this.id, 
    required this.name, 
    required this.title,
    this.content,
    this.imageUrl,
    this.imageFile,
    this.createdAt,
    required this.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'],
        name: json['name'],
        title: json['title'] ?? "",
        content: json['content'],
        imageUrl: json['image'],
        createdAt: DateTime.parse(json['createdAt']),
        members: List<String>.from(json['members'] ?? []),
      );

    Map<String, dynamic> toJson() {
      return {
        if (id != null) 'id': id,
        'name': name,
        'title': title,
        'content': content,
        if (imageFile != null) 'imageFile': imageToBase64(imageFile),
        if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
        'members': members,
      };
    }

    String? imageToBase64(XFile? imageFile) {
      if (imageFile == null) return null;
      final bytes = File(imageFile.path).readAsBytesSync();
      return base64Encode(bytes);
    }
}
