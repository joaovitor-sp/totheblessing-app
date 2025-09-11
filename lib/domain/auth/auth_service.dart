import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/data/auth/auth_repository.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/auth_provider.dart';
import 'package:totheblessing/services/user_repository.dart'; // Para BuildContext e SnackBar

class AuthService {
  final AuthRepository _authRepository;
  final Ref ref;

  AuthService(this._authRepository, this.ref); // Construtor para injeção de dependência do repositório

  Stream<User?> get user => _authRepository.authStateChanges;

  Future<UserCredential?> signInWithGoogle({required BuildContext context}) async {
    try {
      final UserCredential? userCredential = await _authRepository.signInWithGoogle();
      final String? firebaseIdToken =
      await userCredential!.user!.getIdToken(); // <-- Esse é o que você manda pra API

      if (firebaseIdToken != null) {
        // Atualiza o estado do token no Riverpod
        ref.read(idTokenProvider.notifier).state = firebaseIdToken;

        // Atualiza o token no ApiService (instância única)
        final apiService = ref.read(apiServiceProvider);
        apiService.updateToken(firebaseIdToken);
      }

      print('Firebase ID Token: $firebaseIdToken');
      print('Login com Google bem-sucedido via AuthService: ${userCredential.user?.displayName}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocorreu um erro durante o login com Google.';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Já existe uma conta com o mesmo e-mail, mas com outro método de login.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'As credenciais fornecidas são inválidas.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorreu um erro inesperado. Tente novamente.')),
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}