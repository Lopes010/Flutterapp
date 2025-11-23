// lib/features/atendimento/data/repositories/atendimento_repository_impl.dart
import 'package:aplicativo/features/atendimento/domain/entities/atendimento.dart';
import 'package:aplicativo/features/atendimento/domain/repositories/atendimento_repository.dart';
import 'package:aplicativo/features/atendimento/data/datasources/database_helper.dart';
import 'package:aplicativo/features/atendimento/data/models/atendimento_model.dart';

class AtendimentoRepositoryImpl implements AtendimentoRepository {
  final DatabaseHelper dbHelper;

  AtendimentoRepositoryImpl({required this.dbHelper});

  @override
  Future<List<Atendimento>> getAtendimentos() async {
    final models = await dbHelper.getAtendimentos();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Atendimento>> getAtendimentosPorStatus(StatusAtendimento status) async {
    final models = await dbHelper.getAtendimentosPorStatus(status);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Atendimento?> getAtendimento(int id) async {
    final model = await dbHelper.getAtendimentoById(id);
    return model?.toEntity(); // Usando ?. para evitar null
  }

  @override
  Future<int> insertAtendimento(Atendimento atendimento) async {
    final model = AtendimentoModel.fromEntity(atendimento);
    return await dbHelper.insertAtendimento(model);
  }

  @override
  Future<int> updateAtendimento(Atendimento atendimento) async {
    final model = AtendimentoModel.fromEntity(atendimento.copyWith(
      dataAtualizacao: DateTime.now(),
    ));
    return await dbHelper.updateAtendimento(model);
  }

  @override
  Future<int> deleteAtendimento(int id) async {
    return await dbHelper.deleteAtendimento(id);
  
  }
  @override
  Future<int> updateAtendimentoImagem(int id, String imagemPath) async {
  return await dbHelper.updateAtendimentoWithImage(id, imagemPath);
 }
  
  
  
  }
