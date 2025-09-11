import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/models/post_model.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';
import 'package:totheblessing/services/post_repository.dart';

class PostsMapParams {
  final String groupId;
  final String? userId;
  final int? year;
  final int? month;

  PostsMapParams({
    required this.groupId,
    this.userId,
    this.year,
    this.month,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostsMapParams &&
        other.groupId == groupId &&
        other.userId == userId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => Object.hash(groupId, userId, year, month);
}

class MonthView extends ConsumerStatefulWidget {
  final int year;
  final int month;
  // Você pode adicionar um Map<DateTime, List<String>> para fotos aqui depois,
  // ou uma função de callback para o clique em um dia.

  const MonthView({
    super.key,
    required this.year,
    required this.month,
  });
  @override
  MonthViewState createState() => MonthViewState();
}

class MonthViewState extends ConsumerState<MonthView> {
  late final int year;
  late final int month;
  late final UserModel? user;
  late final GroupModel? group;
  late final PostRepository postRepository;

  // Mapa de posts por dia
  Map<int, PostModel> postsMap = {};

  @override
  void initState() {
    super.initState();
    year = widget.year;
    month = widget.month;
    user = ref.read(activeUserProvider);
    group = ref.read(activeGroupProvider);

    // Provider do repository
    postRepository = ref.read(postRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || group == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final asyncPostsMap = ref.watch(postsMapProvider(
      PostsMapParams(
        groupId: group!.id!,
        userId: user!.id,
        year: year,
        month: month,
      ),
    ));
    // 1. Calcular o número de dias no mês
    final DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);
    final DateTime lastDayOfMonth =
        firstDayOfNextMonth.subtract(const Duration(days: 1));
    final int daysInMonth = lastDayOfMonth.day;

    // 2. Calcular o dia da semana do primeiro dia do mês
    // DateTime.weekday retorna: 1=Seg, 2=Ter, ..., 7=Dom
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int weekdayOfFirstDay =
        firstDayOfMonth.weekday; // 1 (Monday) .. 7 (Sunday)

    // Converter para um índice baseado em 0, onde Domingo = 0, Segunda = 1, etc.
    // Isso é útil para alinhar no GridView.
    // Se o seu calendário começa na Segunda-feira, não precisa dessa conversão.
    // Mas se quiser Domingo como o primeiro dia da semana, pode ser:
    // int startWeekdayIndex = weekdayOfFirstDay % 7; // Domingo (7) vira 0, Segunda (1) vira 1.
    // Para simplificar, vamos manter o 1=Segunda, e adicionar `Sexta, Sábado, Domingo` na lista dos dias da semana.

    // Nomes dos dias da semana (em português, para o exemplo)
    // Se seu calendário começa no domingo, mude a ordem aqui.
    const List<String> weekDays = [
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom'
    ];

    // Nome do mês (exemplo simples, você pode usar o pacote intl para localização)
    final String monthName = _getMonthName(month);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Mês
          Center(
            child: Text(
              '$monthName $year',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // Card com os Dias da Semana e os Números dos Dias
          Card(
            elevation: 2,
            color: const Color.fromARGB(255, 229, 196,
                180), // Fundo bege/marrom claro. Experimente outros tons, como Colors.amber[50] para um beje mais amarelado.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Colors.brown, // Cor da borda
                width: 1.5, // Largura da borda
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Cabeçalho dos dias da semana (Seg, Ter, Qua...)
                  GridView.builder(
                    shrinkWrap:
                        true, // Importante para GridView dentro de Column/ListView
                    physics:
                        const NeverScrollableScrollPhysics(), // Evita rolagem própria
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, // 7 dias na semana
                      childAspectRatio: 1.0, // Células quadradas
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          weekDays[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 1,
                  ), // Linha separadora

                  // Números dos Dias do Mês
                  asyncPostsMap.when(
                    data: (postsMap) {
                      final weekdayOfFirstDay =
                          DateTime(year, month, 1).weekday;
                      final daysInMonth = DateTime(year, month + 1, 0).day;

                      final totalItemCount =
                          (weekdayOfFirstDay - 1) + daysInMonth;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                        ),
                        itemCount: totalItemCount,
                        itemBuilder: (context, index) {
                          final day = index - (weekdayOfFirstDay - 1) + 1;
                          final currentDay = DateTime(year, month, day);
                          final isWeekend =
                              currentDay.weekday == DateTime.saturday ||
                                  currentDay.weekday == DateTime.sunday;

                          if (index < (weekdayOfFirstDay - 1) ||
                              day > daysInMonth) {
                            return const SizedBox.shrink();
                          }

                          final post = postsMap[day];
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // Borda arredondada
                              borderRadius: BorderRadius.circular(
                                  50), // Define um raio de 12 para todas as pontas
                              image: post != null
                                  ? DecorationImage(
                                      image: post.imageUrl != null &&
                                              post.imageUrl!.isNotEmpty
                                          ? NetworkImage(post.imageUrl!)
                                          : const AssetImage(
                                                  "assets/images/default_calendar_image.png")
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: post == null
                                ? Center(
                                    child: Text(
                                      "$day",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isWeekend
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  )
                                : null, // Não exibe nada se houver uma imagem
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text("Erro: $err")),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }
}
