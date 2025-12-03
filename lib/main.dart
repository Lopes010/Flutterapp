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
import 'features/atendimento/presentation/pages/splash_screen.dart'; // ✅ Importação adicionada

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
    return RepositoryProvider(
      create: (BuildContext context) => AtendimentoRepositoryImpl(dbHelper: dbHelper),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => AtendimentoListCubit(
              getAtendimentos: GetAtendimentos(RepositoryProvider.of<AtendimentoRepositoryImpl>(context)),
              getAtendimentosPorStatus: GetAtendimentosPorStatus(RepositoryProvider.of<AtendimentoRepositoryImpl>(context)),
              deleteAtendimento: DeleteAtendimento(RepositoryProvider.of<AtendimentoRepositoryImpl>(context)),
            ),
          ),
          BlocProvider(
            create: (BuildContext context) => AtendimentoFormCubit(
              createAtendimento: CreateAtendimento(RepositoryProvider.of<AtendimentoRepositoryImpl>(context)),
              updateAtendimento: UpdateAtendimento(RepositoryProvider.of<AtendimentoRepositoryImpl>(context)),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Sistema de Atendimentos',
          theme: ThemeData(
            primarySwatch: Colors.brown,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const SplashScreen(), // ✅ Alterado para SplashScreen
        ),
      ),
    );
  }
}