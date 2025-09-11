import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/providers/data_provider.dart';

class ListGroupsPage extends ConsumerWidget {
  const ListGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grupos = ref.watch(userGroupsProvider);

    void createGroup() {
      Navigator.pushNamed(context, AppRoutes.createGroup);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6), // tom bege claro
      appBar: AppBar(
        title: const Text("Seus Grupos", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF8B5E3C), // marrom quente
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensagem de boas-vindas
            const Text(
              "Bem-vindo! 🙏\nSelecione um grupo para continuar ou crie um novo.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E3C),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de grupos
            Expanded(
              child: grupos.isEmpty
                  ? Center(
                      child: Text(
                        "Você ainda não tem grupos. Crie um novo!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown[400],
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: grupos.length,
                      itemBuilder: (context, index) {
                        final grupo = grupos[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(activeGroupProvider.notifier).state = grupo;
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.home);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: const Color(0xFFFFF8F0), // bege mais claro para card
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grupo.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5C3A21), // marrom escuro
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    grupo.content ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.brown[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Botão de criar novo grupo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  "Criar Novo Grupo",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF8B5E3C), // marrom botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: createGroup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
