import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importe para usar o Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/providers/data_provider.dart';

class InvitePage extends ConsumerWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGroup = ref.read(activeGroupProvider);

    const String baseUrl = 'https://to-the-blessing.web.app';

    final String inviteLink =
        '$baseUrl/accept_invite?groupId=${activeGroup != null ? activeGroup.id : ""}';

    // Verifica se o groupId é nulo e mostra uma mensagem de erro, se necessário.
    if (activeGroup == null || activeGroup.id == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invite Link'),
        ),
        body: const Center(
          child: Text(
            'Erro: Grupo não encontrado.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidar para o Grupo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Compartilhe este link para convidar novos membros:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Card para exibir o link de forma elegante.
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      // Texto do link
                      Expanded(
                        child: SelectableText(
                          inviteLink,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 3,
                        ),
                      ),
                      // Ícone para copiar o link.
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                          // Copia o link para a área de transferência.
                          Clipboard.setData(ClipboardData(text: inviteLink))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copiado!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
