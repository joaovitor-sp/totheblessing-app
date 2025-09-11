import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';
import 'package:totheblessing/services/group_repository.dart';

final createGroupControllerProvider = Provider<CreateGroupController>((ref) {
  return CreateGroupController(ref);
});

class CreateGroupController {
  final Ref ref;

  CreateGroupController(this.ref);

  Future<void> createGroup(
      {required String title,
      required String name,
      String? content,
      XFile? image,
      required List<String> members}) async {
    try {
      final GroupRepository groupRepository = ref.read(groupRepositoryProvider);
      final newGroup = GroupModel(
        title: title,
        content: content,
        imageFile: image,
        members: members,
        name: name,
      );
      if (newGroup.imageFile == null) return;
      final GroupModel group = await groupRepository.createGroup(newGroup);
      await saveGroup(group);
      print('Group criado com sucesso!');
    } catch (e) {
      print('Erro ao criar group: $e');
    }
  }

  // Salvar grupo ativo
  Future<void> saveGroup(GroupModel group) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('groupData', jsonEncode(group.toJson()));
    ref.read(activeGroupProvider.notifier).state = group;
    ref.read(userGroupsProvider.notifier).update((groups) {
      final exists = groups.any((g) => g.id == group.id);
      if (!exists) {
        return [...groups, group];
      }
      return groups;
    });
  }
}
