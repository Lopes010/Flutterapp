import 'package:flutter_bloc/flutter_bloc.dart';
import '.././../domain/entities/atendimento.dart';
import '.././../domain/usecases/get_atendimentos.dart';
import '.././../domain/usecases/get_atendimentos_por_status.dart';
import '.././../domain/usecases/delete_atendimento.dart';

// CORRIJA ESTA LINHA - deve ser part, não import
part 'atendimento_state.dart';

class AtendimentoListCubit extends Cubit<AtendimentoListState> {
  final GetAtendimentos getAtendimentos;
  final GetAtendimentosPorStatus getAtendimentosPorStatus;
  final DeleteAtendimento deleteAtendimento;

  AtendimentoListCubit({
    required this.getAtendimentos,
    required this.getAtendimentosPorStatus,
    required this.deleteAtendimento,
  }) : super(AtendimentoListInitial()); // ← Esta classe deve estar no state file

  Future<void> loadAtendimentos() async {
    emit(AtendimentoListLoading());
    try {
      final atendimentos = await getAtendimentos();
      emit(AtendimentoListLoaded(atendimentos: atendimentos));
    } catch (e) {
      emit(AtendimentoListError(message: 'Erro ao carregar atendimentos: $e'));
    }
  }

  Future<void> filterByStatus(StatusAtendimento status) async {
    emit(AtendimentoListLoading());
    try {
      final atendimentos = await getAtendimentosPorStatus(status);
      emit(AtendimentoListLoaded(atendimentos: atendimentos));
    } catch (e) {
      emit(AtendimentoListError(message: 'Erro ao filtrar atendimentos: $e'));
    }
  }

  Future<void> deleteAtendimentoById(int id) async {
    try {
      await deleteAtendimento.call(id);
      await loadAtendimentos();
    } catch (e) {
      emit(AtendimentoListError(message: 'Erro ao excluir atendimento: $e'));
    }
  }
}