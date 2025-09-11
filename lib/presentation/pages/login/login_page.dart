import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/data/local_storage/group_data.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/presentation/pages/login/login_controller.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

  Future<void> login() async {
    final controller = ref.read(loginControllerProvider);
    final result = await controller.signInWithGoogle(context: context);
    if (result != null && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  } 
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Erro ao carregar usuário: $err')),
      ),
      data: (user) {
        if (user != null) {
          // Redireciona para home se já estiver logado
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final List<String> userGroupsIds = user.groups;
            if(userGroupsIds.isNotEmpty){
              final groupRepository = ref.read(groupRepositoryProvider);
              final groupData = ref.read(groupDataProvider);
              final List<GroupModel> userGroups = await groupRepository.getGroups(userGroupsIds);
              await groupData.saveGroupList(userGroups);
            }
            if(!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          });
          return const SizedBox.shrink();
        }

        // Usuário não logado, mostra tela de login
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
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Image.asset('assets/images/bibleIcon.png', height: 150),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        "Meus Momentos com Deus",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(
                          color: const Color(0xFF7A4E2D),
                          fontWeight: FontWeight.w400,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Text(
                        "Bem-vindo ao seu espaço com Deus. Registre seus momentos de oração, meditação e fé.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.brown.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: login,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(width: 8),
                            Image.asset('assets/images/google_logo.png', height: 24, width: 24),
                            const SizedBox(width: 24),
                            Text(
                              'Entrar com Google',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.brown[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 32),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Text(
                        "Aquietai-vos, e sabeis que eu sou Deus. Salmos 46:10",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
