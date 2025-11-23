// lib/features/atendimento/data/models/atendimento_model.dart
import 'package:aplicativo/features/atendimento/domain/entities/atendimento.dart';

class AtendimentoModel {
  int? id;
  String descricao;
  int status; // 0=ativo, 1=emAndamento, 2=finalizado, 3=deletado
  String? imagemPath;
  String? anotacoes;
  String dataCriacao;
  String? dataAtualizacao;

  AtendimentoModel({
    this.id,
    required this.descricao,
    required this.status,
    this.imagemPath,
    this.anotacoes,
    required this.dataCriacao,
    this.dataAtualizacao,
  });

  // Converter para Map para o SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'status': status,
      'imagemPath': imagemPath,
      'anotacoes': anotacoes,
      'dataCriacao': dataCriacao,
      'dataAtualizacao': dataAtualizacao,
    };
  }

  // Converter de Map para AtendimentoModel
  factory AtendimentoModel.fromMap(Map<String, dynamic> map) {
    return AtendimentoModel(
      id: map['id'],
      descricao: map['descricao'],
      status: map['status'],
      imagemPath: map['imagemPath'],
      anotacoes: map['anotacoes'],
      dataCriacao: map['dataCriacao'],
      dataAtualizacao: map['dataAtualizacao'],
    );
  }

  // Converter para Entidade
  Atendimento toEntity() {
    return Atendimento(
      id: id,
      descricao: descricao,
      status: StatusAtendimento.values[status],
      imagemPath: imagemPath,
      anotacoes: anotacoes,
      dataCriacao: DateTime.parse(dataCriacao),
      dataAtualizacao: dataAtualizacao != null ? DateTime.parse(dataAtualizacao!) : null,
    );
  }

  // Converter de Entidade para Model
  factory AtendimentoModel.fromEntity(Atendimento entity) {
    return AtendimentoModel(
      id: entity.id,
      descricao: entity.descricao,
      status: entity.status.index,
      imagemPath: entity.imagemPath,
      anotacoes: entity.anotacoes,
      dataCriacao: entity.dataCriacao.toIso8601String(),
      dataAtualizacao: entity.dataAtualizacao?.toIso8601String(),
    );
  }
}