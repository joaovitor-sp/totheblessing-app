import 'package:flutter/material.dart';
import 'package:totheblessing/presentation/widgets/month_view.dart';

class CalendarPostPage extends StatefulWidget {
  // A data inicial de onde o calendário deve começar a ser exibido
  // Você pode passar essa data de onde você navegar para esta página.
  // final DateTime startDate = ;

  const CalendarPostPage({
    super.key,
  });

  @override
  State<CalendarPostPage> createState() => _CalendarPostPageState();
}

class _CalendarPostPageState extends State<CalendarPostPage> {
  late final DateTime startDate;
  late final DateTime _endDate; // A data final (hoje)
  late final int _numberOfMonths; // Quantidade de meses a serem exibidos

  @override
  void initState() {
    super.initState();
    // TODO: data inicial fixa por enquanto
    startDate = DateTime(2024, 1, 1);
    // A data final será o dia 1 do mês atual para simplificar o cálculo
    _endDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

    // Calcula a diferença em meses entre a startDate e a _endDate
    // Adiciona 1 para incluir o mês de início e o mês de fim
    _numberOfMonths = (_endDate.year - startDate.year) * 12 +
        (_endDate.month - startDate.month) +
        1;

    // Garante que o número de meses seja pelo menos 1 (se a data inicial for o mês atual ou futuro)
    if (_numberOfMonths < 1) {
      _numberOfMonths = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        // Exibe os meses na ordem inversa (do mais recente para o mais antigo)
        // Isso fará com que o mês atual esteja no topo, e você role para baixo para ver os meses passados.
        // Se preferir do mais antigo para o mais recente, mude o order by aqui.
        reverse:
            true, // Começa do final (mês atual) e rola para ver os anteriores
        itemCount: _numberOfMonths,
        itemBuilder: (context, index) {
          // Calcula o mês e ano para exibir:
          // index 0 = Mês atual (_endDate)
          // index 1 = Mês anterior
          // ...
          // index N = Mês inicial (startDate)
          final DateTime monthToDisplay = DateTime(
            _endDate.year,
            _endDate.month -
                index, // Subtrai o índice para ir para meses anteriores
            1, // Dia arbitrário, apenas para obter ano e mês
          );

          return MonthView(
            year: monthToDisplay.year,
            month: monthToDisplay.month,
            // Futuramente, você passará os dados dos posts para cada MonthView aqui.
            // postsForMonth: yourPostsDataManager.getPostsForMonth(monthToDisplay),
          );
        },
      ),
    );
  }
}
