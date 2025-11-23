part of 'atendimento_form_cubit.dart';

abstract class AtendimentoFormState {
  const AtendimentoFormState();
}

class AtendimentoFormInitial extends AtendimentoFormState {}

class AtendimentoFormEditing extends AtendimentoFormState {
  final Atendimento atendimento;

  const AtendimentoFormEditing({required this.atendimento});
}

class AtendimentoFormSaving extends AtendimentoFormState {}

class AtendimentoFormSuccess extends AtendimentoFormState {
  final int id;

  const AtendimentoFormSuccess({required this.id});
}

class AtendimentoFormError extends AtendimentoFormState {
  final String message;

  const AtendimentoFormError({required this.message});
}