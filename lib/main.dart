import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/atendimento/data/datasources/database_helper.dart';
import 'features/atendimento/data/repositories/atendimento_repository_impl.dart';
import 'features/atendimento/domain/usecases/get_atendimentos.dart';
import 'features/atendimento/domain/usecases/get_atendimentos_por_status.dart';
import 'features/atendimento/domain/usecases/create_atendimento.dart';
import 'features/atendimento/domain/usecases/update_atendimento.dart';
import 'features/atendimento/domain/usecases/delete_atendimento.dart';
import 'features/atendimento/domain/usecases/update_atendimento_imagem.dart';
import 'features/atendimento/presentation/cubits/atendimento_list_cubit.dart';
import 'features/atendimento/presentation/cubits/atendimento_form_cubit.dart';
import 'features/atendimento/presentation/pages/atendimento_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper();
  await dbHelper.testDatabase();
  print("✅ Banco de dados inicializado!");
  
  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AtendimentoRepositoryImpl>(
          create: (context) => AtendimentoRepositoryImpl(dbHelper: dbHelper),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AtendimentoListCubit>(
            create: (context) => AtendimentoListCubit(
              getAtendimentos: GetAtendimentos(context.read<AtendimentoRepositoryImpl>()),
              getAtendimentosPorStatus: GetAtendimentosPorStatus(context.read<AtendimentoRepositoryImpl>()),
              deleteAtendimento: DeleteAtendimento(context.read<AtendimentoRepositoryImpl>()),
            ),
          ),
          BlocProvider<AtendimentoFormCubit>(
            create: (context) => AtendimentoFormCubit(
              createAtendimento: CreateAtendimento(context.read<AtendimentoRepositoryImpl>()),
              updateAtendimento: UpdateAtendimento(context.read<AtendimentoRepositoryImpl>()),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Sistema de Atendimentos',
          theme: ThemeData(
            primarySwatch: Colors.brown,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const AtendimentoListPage(),
        ),
      ),
    );
  }
}