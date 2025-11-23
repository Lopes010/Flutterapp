// lib/features/atendimento/domain/usecases/create_atendimento.dart

import '../entities/atendimento.dart';
import '../repositories/atendimento_repository.dart';

class CreateAtendimento {
  final AtendimentoRepository repository;

  CreateAtendimento(this.repository);

  Future<int> call({
    required String descricao,
    String? imagemPath,
    String? anotacoes,
  }) async {
    final atendimento = Atendimento(
      descricao: descricao,
      status: StatusAtendimento.ativo,
      dataCriacao: DateTime.now(),
      imagemPath: imagemPath,
      anotacoes: anotacoes,
    );
    
    return await repository.insertAtendimento(atendimento);
  }
}