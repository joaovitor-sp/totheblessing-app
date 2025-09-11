import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';

class GroupDetailsPage extends ConsumerWidget {
  const GroupDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GroupModel group = ref.watch(activeGroupProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: const Color(0xFF8B5E3C), // tom marrom
        actions: [
          Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz), // Ícone do botão
                  onSelected: (value) {
                    // Aqui você trata a opção clicada
                    if (value == 'editGroup') {
                      // abrir invite
                      Navigator.pushNamed(
                        context,
                        AppRoutes.groupEdit,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editGroup',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do grupo
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: group.imageUrl != null && group.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(group.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image:
                            AssetImage("assets/images/default_calendar_image.png"),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Informações do grupo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3A21), // marrom escuro
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content
                  if (group.content != null && group.content!.isNotEmpty)
                    Text(
                      group.content!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown[700],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Lista de usuários
                  const Text(
                    "Membros do Grupo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<UserModel>>(
                    future: ref.read(userRepositoryProvider).getUsers(group.members),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(
                          "Erro ao carregar usuários: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Nenhum membro encontrado.");
                      } else {
                        final users = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.perfilImage != null &&
                                        user.perfilImage!.isNotEmpty
                                    ? NetworkImage(user.perfilImage!)
                                    : const AssetImage(
                                            "assets/images/default_calendar_image.png")
                                        as ImageProvider,
                              ),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
