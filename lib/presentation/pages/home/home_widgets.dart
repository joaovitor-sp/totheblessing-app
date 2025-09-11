import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/data/local_storage/group_data.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/providers/data_provider.dart';

Widget groupNameWidget(WidgetRef ref) {
  final activeGroup = ref.watch(activeGroupProvider);

  if (activeGroup != null) {
    return Text(
      activeGroup.name,
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
    );
  } else {
    return FutureBuilder<GroupModel?>(
      future: ref.read(groupDataProvider).loadGroup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // Atualiza o provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(activeGroupProvider.notifier).state = snapshot.data;
          });
          return Text(
            snapshot.data!.name,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          );
        } else {
          return const Text(
            'Nenhum grupo ativo',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          );
        }
      },
    );
  }
}
