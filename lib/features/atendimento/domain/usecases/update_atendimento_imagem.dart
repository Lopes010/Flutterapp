import '../repositories/atendimento_repository.dart';

class UpdateAtendimentoImagem {
  final AtendimentoRepository repository;

  UpdateAtendimentoImagem(this.repository);

  Future<int> call(int id, String imagemPath) async {
    return await repository.updateAtendimentoImagem(id, imagemPath);
  }
}