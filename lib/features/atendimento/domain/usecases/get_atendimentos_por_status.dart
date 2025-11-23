import '../entities/atendimento.dart';
import '../repositories/atendimento_repository.dart';

class GetAtendimentosPorStatus {
  final AtendimentoRepository repository;

  GetAtendimentosPorStatus(this.repository);

  Future<List<Atendimento>> call(StatusAtendimento status) async {
    return await repository.getAtendimentosPorStatus(status);
  }
}