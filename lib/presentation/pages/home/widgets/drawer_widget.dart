import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/data/local_storage/user_data.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/presentation/pages/create_group/create_group_controller.dart';
import 'package:totheblessing/providers/data_provider.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pega o grupo ativo do usuário
    final userGroups = ref.watch(userGroupsProvider);
    void goToHome() {
      // ação ao clicar em Início
      print("Início");
    }

    void createGroup() {
      // ação ao clicar em Criar Grupo
      Navigator.pushNamed(context, AppRoutes.createGroup);
    }

    void openSettings() {
      // ação ao clicar em Configurações
      print("Configurações");
    }

    return Drawer(
      backgroundColor: const Color.fromARGB(255, 175, 120, 81),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<UserModel?>(
            future: ref.read(userDataProvider).loadUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircleAvatar(radius: 16),
                  title: Text("Carregando..."),
                );
              }
              if (snapshot.hasError) {
                return const ListTile(
                  leading: Icon(Icons.error),
                  title: Text("Erro ao carregar"),
                );
              }
              final user = snapshot.data;
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: user?.perfilImage != null
                      ? CachedNetworkImageProvider(user!.perfilImage!)
                      : null,
                  child: user?.perfilImage == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                    user != null ? user.name : "Erro ao carregar seu Usuario!"),
                onTap: goToHome,
              );
            },
          ),
          ...userGroups.map((group) => ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: group.imageUrl != null
                      ? CachedNetworkImageProvider(group.imageUrl!)
                      : null,
                  child:
                      group.imageUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(group.name),
                onTap: () {
                  ref.read(createGroupControllerProvider).saveGroup(group);
                  // Navega para a rota home e remove todas as rotas anteriores.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              )),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_outlined),
            title: const Text('Criar Grupo'),
            onTap: createGroup,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: openSettings,
          ),
        ],
      ),
    );
  }
}
