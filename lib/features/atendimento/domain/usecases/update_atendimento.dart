// lib/features/atendimento/domain/usecases/update_atendimento.dart

import '../entities/atendimento.dart';
import '../repositories/atendimento_repository.dart';

class UpdateAtendimento {
  final AtendimentoRepository repository;

  UpdateAtendimento(this.repository);

  Future<int> call(Atendimento atendimento) async {
    return await repository.updateAtendimento(atendimento);
  }
}