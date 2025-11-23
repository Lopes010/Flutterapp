// lib/domain/repositories/atendimento_repository.dart

import '../entities/atendimento.dart';

abstract class AtendimentoRepository {
  Future<List<Atendimento>> getAtendimentos();
  Future<List<Atendimento>> getAtendimentosPorStatus(StatusAtendimento status);
  Future<Atendimento?> getAtendimento(int id);
  Future<int> insertAtendimento(Atendimento atendimento);
  Future<int> updateAtendimento(Atendimento atendimento);
  Future<int> deleteAtendimento(int id);
  Future<int> updateAtendimentoImagem(int id, String imagemPath);

}