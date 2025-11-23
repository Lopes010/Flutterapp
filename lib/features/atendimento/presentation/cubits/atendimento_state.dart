
part of 'atendimento_list_cubit.dart';

// ... resto do código ...

abstract class AtendimentoListState {
  const AtendimentoListState();
}

class AtendimentoListInitial extends AtendimentoListState {}

class AtendimentoListLoading extends AtendimentoListState {}

class AtendimentoListLoaded extends AtendimentoListState {
  final List<Atendimento> atendimentos;

  const AtendimentoListLoaded({required this.atendimentos});
}

class AtendimentoListError extends AtendimentoListState {
  final String message;

  const AtendimentoListError({required this.message});
}