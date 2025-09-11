import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/providers/data_provider.dart';

final userDataProvider = Provider<UserData>((ref) {
  return UserData(ref);
});

class UserData {
  final Ref ref;

  UserData(
      this.ref);
  // salvar
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', jsonEncode(user.toJson()));
    ref.read(activeUserProvider.notifier).state = user;
  }

  // Carregar
  Future<UserModel?> loadUser() async {
    final activeUser = ref.read(activeUserProvider.notifier);
    if(activeUser.state != null) return activeUser.state;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userData');
    if (jsonString == null) return null;
    UserModel user = UserModel.fromJson(jsonDecode(jsonString));
    activeUser.state = user;
    return user;
  }

  // pega o token Id do usuario
  Future<String?> getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // força refresh para garantir token válido
      return await user.getIdToken(true);
    }
    return null;
  }

  void cleanUserData() {
    
  }
}