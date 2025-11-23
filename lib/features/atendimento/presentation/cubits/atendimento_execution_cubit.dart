import 'package:flutter_bloc/flutter_bloc.dart';
import '../.././domain/entities/atendimento.dart';
import '.././../domain/usecases/update_atendimento.dart';
import '.././../domain/usecases/update_atendimento_imagem.dart';

part 'atendimento_execution_state.dart';

class AtendimentoExecutionCubit extends Cubit<AtendimentoExecutionState> {
  final UpdateAtendimento updateAtendimento;
  final UpdateAtendimentoImagem updateAtendimentoImagem;

  AtendimentoExecutionCubit({
    required this.updateAtendimento,
    required this.updateAtendimentoImagem,
  }) : super(AtendimentoExecutionInitial());

  void loadAtendimento(Atendimento atendimento) {
    emit(AtendimentoExecutionLoaded(
      atendimento: atendimento,
      imagemPath: atendimento.imagemPath,
      observations: atendimento.anotacoes,
    ));
  }

  void updateImage(String imagePath) async {
    try {
      final currentState = state;
      if (currentState is AtendimentoExecutionLoaded) {
        await updateAtendimentoImagem.call(currentState.atendimento.id!, imagePath);
        emit(currentState.copyWith(imagemPath: imagePath));
      }
    } catch (e) {
      emit(AtendimentoExecutionError(message: 'Erro ao salvar imagem: $e'));
    }
  }

  void updateObservations(String observations) async {
    try {
      final currentState = state;
      if (currentState is AtendimentoExecutionLoaded) {
        final updatedAtendimento = currentState.atendimento.copyWith(
          anotacoes: observations,
          dataAtualizacao: DateTime.now(),
        );
        
        await updateAtendimento.call(updatedAtendimento);
        emit(currentState.copyWith(observations: observations));
      }
    } catch (e) {
      emit(AtendimentoExecutionError(message: 'Erro ao salvar observações: $e'));
    }
  }

  Future<void> saveAtendimento() async {
    final currentState = state;
    if (currentState is AtendimentoExecutionLoaded) {
      emit(AtendimentoExecutionSaving());
      try {
        await updateAtendimento.call(currentState.atendimento);
        emit(AtendimentoExecutionSuccess());
      } catch (e) {
        emit(AtendimentoExecutionError(message: 'Erro ao salvar atendimento: $e'));
      }
    }
  }

  Future<void> finalizeAtendimento() async {
    final currentState = state;
    if (currentState is AtendimentoExecutionLoaded) {
      emit(AtendimentoExecutionSaving());
      try {
        print('🔄 Finalizando atendimento ID: ${currentState.atendimento.id}');
        
        final atendimentoFinalizado = currentState.atendimento.copyWith(
          status: StatusAtendimento.finalizado,
          dataAtualizacao: DateTime.now(),
        );

        await updateAtendimento.call(atendimentoFinalizado);
        
        print('✅ Atendimento finalizado com sucesso!');
        emit(AtendimentoExecutionSuccess());
      } catch (e) {
        print('❌ Erro: $e');
        emit(AtendimentoExecutionError(message: 'Erro ao finalizar atendimento: $e'));
      }
    }
  }
}

