part of 'atendimento_execution_cubit.dart';

abstract class AtendimentoExecutionState {
  const AtendimentoExecutionState();
}

class AtendimentoExecutionInitial extends AtendimentoExecutionState {}

class AtendimentoExecutionLoaded extends AtendimentoExecutionState {
  final Atendimento atendimento;
  final String? imagemPath;
  final String? observations;

  const AtendimentoExecutionLoaded({
    required this.atendimento,
    this.imagemPath,
    this.observations,
  });

  AtendimentoExecutionLoaded copyWith({
    Atendimento? atendimento,
    String? imagemPath,
    String? observations,
  }) {
    return AtendimentoExecutionLoaded(
      atendimento: atendimento ?? this.atendimento,
      imagemPath: imagemPath ?? this.imagemPath,
      observations: observations ?? this.observations,
    );
  }
}

class AtendimentoExecutionSaving extends AtendimentoExecutionState {}

class AtendimentoExecutionSuccess extends AtendimentoExecutionState {}

class AtendimentoExecutionError extends AtendimentoExecutionState {
  final String message;

  const AtendimentoExecutionError({required this.message});
}