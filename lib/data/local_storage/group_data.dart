import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/providers/data_provider.dart';

final groupDataProvider = Provider<GroupData>((ref) {
  return GroupData(ref);
});

class GroupData {
  final Ref ref;

  GroupData(this.ref);

  // Carregar grupo ativo
  Future<GroupModel?> loadGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('groupData');
    if (jsonString == null) return null;
    GroupModel group = GroupModel.fromJson(jsonDecode(jsonString));
    return group;
  }

  // Salvar lista de grupos
  Future<void> saveGroupList(List<GroupModel> groups) async {
    ref.read(userGroupsProvider.notifier).state = groups;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = groups.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList('groupList', jsonList);
  }

  // Carregar lista de grupos
  Future<List<GroupModel>> loadGroupList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('groupList');
    if (jsonList == null) return [];
    return jsonList.map((g) => GroupModel.fromJson(jsonDecode(g))).toList();
  }
}