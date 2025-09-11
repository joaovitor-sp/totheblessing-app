import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/models/post_model.dart';
import 'package:totheblessing/services/api_service.dart';
import 'package:totheblessing/providers/auth_provider.dart';
import 'package:totheblessing/services/group_repository.dart';
import 'package:totheblessing/services/post_repository.dart';
import 'package:totheblessing/services/user_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(null);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PostRepository(apiService: apiService);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return GroupRepository(apiService: apiService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return UserRepository(apiService: apiService);
});
