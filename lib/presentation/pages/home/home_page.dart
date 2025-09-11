import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/presentation/pages/home/home_widgets.dart';
import 'package:totheblessing/presentation/pages/home/widgets/drawer_widget.dart';
import 'package:totheblessing/presentation/pages/home/widgets/group_card_widget.dart';
import 'package:totheblessing/presentation/pages/home/widgets/post_card_widget.dart';
import 'package:totheblessing/presentation/pages/login/login_controller.dart';
import 'package:totheblessing/presentation/widgets/month_view.dart';
import 'package:totheblessing/providers/data_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // setState(() {
    //   _selectedIndex = index;
    // });

    // // Se quiser navegar para rotas diferentes:
    // if (index == 1) {
    //   Navigator.pushNamed(context, AppRoutes.bible); // Exemplo
    // } else if (index == 2) {
    //   Navigator.pushNamed(context, AppRoutes.profile); // Exemplo
    // }
  }

  @override
  void initState() {
    super.initState();

    // Executa depois que o widget é renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeGroup = ref.watch(activeGroupProvider);

      if (activeGroup == null) {
        // Redireciona para outra página
        Navigator.popAndPushNamed(context, AppRoutes.listGroups);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupModel? group = ref.watch(activeGroupProvider);

    if (group == null) {
      // Opcional: mostrar um placeholder, um loading, etc.
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    LoginController loginController = ref.read(loginControllerProvider);
    final DateTime now = DateTime.now();
    final postsMapAsync = ref.watch(postsMapProvider(
      PostsMapParams(
        groupId: group.id ?? "",
        userId: null,
        year: null,
        month: null,
      ),
    ));

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 233, 210),
            Color.fromARGB(255, 175, 120, 81)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Center(child: groupNameWidget(ref)),
            toolbarHeight: 35,
            backgroundColor: Colors.transparent, // Sem cor de fundo
            elevation: 0, // Sem sombra
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz), // Ícone do botão
                  onSelected: (value) {
                    // Aqui você trata a opção clicada
                    if (value == 'invite') {
                      // abrir invite
                      Navigator.pushNamed(
                        context,
                        AppRoutes.invite,
                      );
                    } else if (value == 'config') {
                      // abrir config
                    } else if (value == 'logout') {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await loginController.logoutUser();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.login,
                        );
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'invite',
                      child: Row(
                        children: [
                          Icon(Icons.add_box_outlined),
                          Text('Convidar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'config',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          Text('Configurações'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.output),
                          Text('Sair'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          drawer: const CustomDrawer(),
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              // Aqui você pode "refrescar" seu provider
              // Por exemplo, invalidar o FutureProvider para forçar novo carregamento
              ref.invalidate(postsMapProvider(
                PostsMapParams(
                  groupId: group.id ?? "",
                  userId: null,
                  year: null,
                  month: null,
                ),
              ));
              // Aguarda um pouco para o efeito visual
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  MonthView(year: now.year, month: now.month),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centraliza a Row na horizontal
                    mainAxisSize: MainAxisSize
                        .min, // **Isso faz a Row ocupar apenas o espaço do seu conteúdo**
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.calendarPosts,
                          );
                        },
                        style:
                            const ButtonStyle(), // Pode remover, já que não há mais a necessidade de ajustar o tamanho
                        child: const Text("Ver todos os posts"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GroupCardWidget(
                    group: group,
                    onTap: () {
                      // Ação ao clicar no card, por exemplo, abrir detalhes do grupo
                      Navigator.pushNamed(context, AppRoutes.groupDetails);
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  postsMapAsync.when(
                    data: (postsMap) {
                      if (postsMap.isEmpty) {
                        return const Center(
                            child: Text("Nenhum post encontrado"));
                      }

                      final sortedDays = postsMap.keys.toList()..sort();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sortedDays.map((day) {
                          final post = postsMap[day]!;
                          final formattedDate = DateFormat('dd/MM/yyyy')
                              .format(post.activityDate);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PostCardWidget(
                                title: post.title,
                                imageUrl: post.imageUrl,
                                description: post.content ?? "",
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Center(child: Text("Erro ao carregar posts: $err")),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.post,
              );
            },
            tooltip: 'Adicionar Novo Item',
            backgroundColor: const Color(0xFFFF7F50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            child: const Icon(
              Icons.add,
              size: 40,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white.withOpacity(0.9),
            selectedItemColor: const Color(0xFFFF7F50),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Bíblia',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
