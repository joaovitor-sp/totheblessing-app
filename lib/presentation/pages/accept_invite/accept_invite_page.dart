import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/presentation/pages/login/login_controller.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';

class AcceptInvitePage extends ConsumerWidget {
  final String groupId;
  const AcceptInvitePage({super.key, required this.groupId});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final activeUser = ref.watch(activeUserProvider);
    final groupRepository = ref.read(groupRepositoryProvider);
    void exit(){
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } 
    void joinGroup() async {
      final GroupModel newGroup = await groupRepository.joinGroup(groupId, activeUser!.id);
      final List<UserModel> usersData = await ref.read(userRepositoryProvider).getUsers([activeUser.id]);
      final UserModel userData = usersData[0];
      ref.read(loginControllerProvider).loadUserData(userData);
      ref.read(activeGroupProvider.notifier).state = newGroup;
      if(!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } 

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Erro ao carregar usuário: $err')),
      ),
      data: (user) {
        if (user == null) {
          // Redireciona para login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }

        // Usuário logado, exibe a página de convite
        return Scaffold(
          appBar: AppBar(title: const Text("Convite")),
          body: FutureBuilder<List<GroupModel>>(
            future:
                groupRepository.getGroups([groupId]), // busca o grupo pelo ID
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Grupo não encontrado'));
              }

              final group = snapshot.data!.first;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome do grupo
                            Row(
                              children: [
                                const Icon(Icons.group,
                                    size: 28, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    group.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Descrição
                            Text(
                              group.content ?? "Sem descrição",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Membros
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(
                                  "${group.members.length} membros",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botão de ação (ex: entrar no grupo ou compartilhar)
                    ElevatedButton.icon(
                      onPressed: joinGroup,
                      icon: const Icon(Icons.login),
                      label: const Text("Participar do grupo"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(
                       height: 8,
                    ),
                    ElevatedButton.icon(
                      onPressed: exit,
                      icon: const Icon(Icons.login),
                      label: const Text("Sair"),
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
