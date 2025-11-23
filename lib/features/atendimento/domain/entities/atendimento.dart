// lib/domain/entities/atendimento.dart

enum StatusAtendimento { ativo, emAndamento, finalizado, deletado }

class Atendimento {
  final int? id;
  final String descricao;
  final StatusAtendimento status;
  final String? imagemPath;
  final String? anotacoes;
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;

  Atendimento({
    this.id,
    required this.descricao,
    required this.status,
    this.imagemPath,
    this.anotacoes,
    required this.dataCriacao,
    this.dataAtualizacao,
  });

  Atendimento copyWith({
    int? id,
    String? descricao,
    StatusAtendimento? status,
    String? imagemPath,
    String? anotacoes,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Atendimento(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      imagemPath: imagemPath ?? this.imagemPath,
      anotacoes: anotacoes ?? this.anotacoes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}