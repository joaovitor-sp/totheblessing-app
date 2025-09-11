// lib/presentation/pages/login/login_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totheblessing/data/local_storage/group_data.dart';
import 'package:totheblessing/data/local_storage/user_data.dart';
import 'package:totheblessing/domain/auth/auth_service.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/auth_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';

final loginControllerProvider = Provider<LoginController>((ref) {
  final repository = ref.read(authServiceProvider);
  return LoginController(repository, ref);
});

// Se você usa GetX, esta classe estenderia GetxController
class LoginController {
  final AuthService _authService;
  final Ref ref;

  LoginController(
      this._authService, this.ref); // Construtor para receber o AuthService

  Future<UserCredential?> signInWithGoogle(
      {required BuildContext context}) async {

    final UserCredential? userCredential =
        await _authService.signInWithGoogle(context: context);
    if(userCredential == null) return null;

    final User userInfo = userCredential.user!;

    final UserModel user = UserModel(
        id: userInfo.uid,
        name: userInfo.displayName ?? "",
        email: userInfo.email ?? "",
        groups: []);
    final UserModel userData = await ref.read(userRepositoryProvider).createUser(user);
    loadUserData(userData);
    
    return userCredential;
  }

  void loadUserData(UserModel userData) async {
    final groupData = ref.read(groupDataProvider);
    final groupRepository = ref.read(groupRepositoryProvider);
    await ref.read(userDataProvider).saveUser(userData);

    final List<String> userGroupsIds = userData.groups;
    if(userGroupsIds.isNotEmpty){
      final List<GroupModel> userGroups = await groupRepository.getGroups(userGroupsIds);
      await groupData.saveGroupList(userGroups);
    }
  }

  Future<void> logoutUser() async {
    _authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ref.read(activeUserProvider.notifier).state = null;
    ref.read(activeGroupProvider.notifier).state = null;
    ref.read(userGroupsProvider.notifier).state = [];
  }

}
