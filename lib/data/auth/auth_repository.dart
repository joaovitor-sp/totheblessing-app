// lib/data/auth/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream para observar o estado de autenticação do usuário
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método para login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuário cancelou o login
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('Google Access Token: ${googleAuth.accessToken}');
      debugPrint('Google ID Token: ${googleAuth.idToken}');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Relança a exceção para ser tratada pela camada de serviço/UI
      debugPrint('##############################################');
      debugPrint('ERRO DE AUTENTICAÇÃO DO FIREBASE (FirebaseAuthException):');
      debugPrint('  Código: ${e.code}');
      debugPrint('  Mensagem: ${e.message}');
      debugPrint('  Plugin: ${e.plugin}');
      debugPrint('  Stack Trace: ${e.stackTrace}'); // Opcional, pode ser muito longo
      debugPrint('##############################################');
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Método para logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
