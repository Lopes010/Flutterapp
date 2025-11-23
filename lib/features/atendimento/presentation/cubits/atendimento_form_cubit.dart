import 'package:flutter_bloc/flutter_bloc.dart';
import '.././../domain/entities/atendimento.dart';
import '.././../domain/usecases/create_atendimento.dart';
import '.././../domain/usecases/update_atendimento.dart';

part 'atendimento_form_state.dart';

class AtendimentoFormCubit extends Cubit<AtendimentoFormState> {
  final CreateAtendimento createAtendimento;
  final UpdateAtendimento updateAtendimento;
  Atendimento? _editingAtendimento;

  AtendimentoFormCubit({
    required this.createAtendimento,
    required this.updateAtendimento,
  }) : super(AtendimentoFormInitial());

  void setEditingAtendimento(Atendimento atendimento) {
    _editingAtendimento = atendimento;
    emit(AtendimentoFormEditing(atendimento: atendimento));
  }
// VERIFIQUE se o método saveAtendimento está EXATAMENTE assim:
Future<void> saveAtendimento({
  required String descricao,
  String? anotacoes,
}) async {
  emit(AtendimentoFormSaving());
  try {
    if (_editingAtendimento != null) {
      // Modo edição
      final atendimentoAtualizado = _editingAtendimento!.copyWith(
        descricao: descricao,
        anotacoes: anotacoes,
        dataAtualizacao: DateTime.now(),
      );
      await updateAtendimento.call(atendimentoAtualizado);
      emit(AtendimentoFormSuccess(id: _editingAtendimento!.id!));
    } else {
      // Modo criação
      final id = await createAtendimento.call(
        descricao: descricao,
        anotacoes: anotacoes,
      );
      emit(AtendimentoFormSuccess(id: id));
    }
  } catch (e) {
    emit(AtendimentoFormError(message: 'Erro ao salvar atendimento: $e'));
  }
}
  
}