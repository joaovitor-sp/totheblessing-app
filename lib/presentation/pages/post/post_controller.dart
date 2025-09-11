import 'package:image_picker/image_picker.dart';
import 'package:totheblessing/models/post_model.dart';
import 'package:totheblessing/services/post_repository.dart';

class PostController {
  final PostRepository postRepository;

  PostController({required this.postRepository});

  Future<void> createPost({
    required String title,
    String? content,
    XFile? imageFile,
    required DateTime activityDate,
    required String authorId,
    required List<String?> groups
  }) async {
    try {
      final newPost = PostModel(
      title: title,
      content: content,
      imageFile: imageFile,
      activityDate: activityDate,
      authorId: authorId,
    );

      await postRepository.createPost(newPost, groups);
      print('Post criado com sucesso!');
    } catch (e) {
      print('Erro ao criar post: $e');
    }
  }
}