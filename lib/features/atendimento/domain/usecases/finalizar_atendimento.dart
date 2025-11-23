// lib/features/atendimento/domain/usecases/finalizar_atendimento.dart

import '../entities/atendimento.dart';
import '../repositories/atendimento_repository.dart';

class FinalizarAtendimento {
  final AtendimentoRepository repository;

  FinalizarAtendimento(this.repository);

  Future<int> call(Atendimento atendimento) async {
    final atendimentoFinalizado = atendimento.copyWith(
      status: StatusAtendimento.finalizado,
      dataAtualizacao: DateTime.now(),
    );
    
    return await repository.updateAtendimento(atendimentoFinalizado);
  }
}