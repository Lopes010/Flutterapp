import '../entities/atendimento.dart';
import '../repositories/atendimento_repository.dart';

class GetAtendimentos {
  final AtendimentoRepository repository;

  GetAtendimentos(this.repository);

  Future<List<Atendimento>> call() async {
    return await repository.getAtendimentos();
  }
}