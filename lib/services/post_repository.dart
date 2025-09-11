import 'package:dio/dio.dart';
import 'package:totheblessing/models/post_model.dart';
import 'api_service.dart';

class PostRepository {
  final ApiService apiService;

  PostRepository({required this.apiService});

  Future<List<PostModel>> getPosts({
    required String groupId,
    String? postId,
    String? authorId,
    int? year,
    int? month,
  }) async {
    DateTime? startDate;
    DateTime? endDate;
    if (year != null && month != null) {
      startDate = DateTime(year, month, 1).toUtc();
      endDate = (month == 12
              ? DateTime(year + 1, 1, 1)
              : DateTime(year, month + 1, 1))
          .toUtc();
    }
    final Map<String, dynamic> queryParams = {
      'groupId': groupId,
    };

    if (postId != null) queryParams['postId'] = postId;
    if (authorId != null) queryParams['authorId'] = authorId;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toUtc().toIso8601String();
    }

    final response =
        await apiService.dio.get('/posts', queryParameters: queryParams);
    List data = response.data;
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> createPost(PostModel post, List<String?> groupsIds) async {
    try {
      final formData = FormData();
      formData.fields
        ..add(MapEntry('title', post.title))
        ..add(MapEntry(
            'authorId', post.authorId)) // se backend espera lista como CSV
        ..add(MapEntry(
            'activityDate', post.activityDate.toUtc().toIso8601String()));

      for (var groupId in groupsIds) {
        formData.fields.add(MapEntry('groupIds', groupId!));
      }
      if (post.content != null) {
        formData.fields.add(MapEntry('content', post.content!));
      }

      if (post.imageFile != null) {
        formData.files.add(
          MapEntry(
            'imageFile',
            await MultipartFile.fromFile(post.imageFile!.path,
                filename: post.imageFile!.name),
          ),
        );
      }
      final response = await apiService.dio.post(
        '/posts',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      final data = response.data;
      if (data != null && data['post'] != null) {
        return PostModel.fromJson(data['post']);
      } else {
        throw Exception('Usuário não encontrado na resposta.');
      }
    } on DioException catch (e) {
      print(
          'Erro ao criar post: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}
