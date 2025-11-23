// lib/features/atendimento/domain/usecases/delete_atendimento.dart

import '../repositories/atendimento_repository.dart';

class DeleteAtendimento {
  final AtendimentoRepository repository;

  DeleteAtendimento(this.repository);

  Future<int> call(int id) async {
    return await repository.deleteAtendimento(id);
  }
}