import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/data/local_storage/user_data.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/models/post_model.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/presentation/widgets/month_view.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/auth_provider.dart';

// Provider para o usuário logado
final activeUserProvider = StateProvider<UserModel?>((ref) => null);

// Provider para o grupo ativo
final activeGroupProvider = StateProvider<GroupModel?>((ref) => null);

// Provider para o grupos do usuario
final userGroupsProvider = StateProvider<List<GroupModel>>((ref) => []);

// login_providers.dart
final currentUserProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final userData = ref.read(userDataProvider);

  // 🔹 Obtém o token do Firebase
  final firebaseIdToken = await userData.getIdToken();

  if (firebaseIdToken != null) {
    // Atualiza o estado do token no Riverpod
    ref.read(idTokenProvider.notifier).state = firebaseIdToken;

    // Atualiza o token no ApiService (instância única)
    ref.read(apiServiceProvider).updateToken(firebaseIdToken);
  }

  // 🔹 Carrega o usuário ativo
  final user = await userData.loadUser();

  // Atualiza o estado do usuário no Riverpod
  ref.read(activeUserProvider.notifier).state = user;

  // Retorna o usuário carregado
  return user;
});

final postsMapProvider =
    FutureProvider.autoDispose.family<Map<int, PostModel>, PostsMapParams>(
        (ref, params) async {
  final repo = ref.read(postRepositoryProvider);

  final posts = await repo.getPosts(
    groupId: params.groupId,
    authorId: params.userId,
    year: params.year,
    month: params.month,
  );

  final map = <int, PostModel>{};
  for (var post in posts) {
    map[post.activityDate.day] = post;
  }

  return map;
});