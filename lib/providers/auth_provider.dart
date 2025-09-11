import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/data/auth/auth_repository.dart';
import 'package:totheblessing/domain/auth/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Estado para guardar o token do Firebase
final idTokenProvider = StateProvider<String?>((ref) => null);

// Instância do AuthService que recebe o ref para atualizar o token
final authServiceProvider = Provider<AuthService>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthService(repository,ref);
});
