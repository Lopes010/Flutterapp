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

  void loadAtendimento(Atendimento atendimento) async {
  try {
    // ✅ ATUALIZA PARA "EM ANDAMENTO" se estiver "ATIVO"
    if (atendimento.status == StatusAtendimento.ativo) {
      print('🔄 Atualizando status para EM ANDAMENTO');
      
      final atendimentoEmAndamento = atendimento.copyWith(
        status: StatusAtendimento.emAndamento,
        dataAtualizacao: DateTime.now(),
      );

      // Salva no banco
      await updateAtendimento.call(atendimentoEmAndamento);
      
      // Emite o estado com o atendimento atualizado
      emit(AtendimentoExecutionLoaded(
        atendimento: atendimentoEmAndamento,
        imagemPath: atendimentoEmAndamento.imagemPath,
        observations: atendimentoEmAndamento.anotacoes,
      ));
    } else {
      // Se já estiver em andamento ou finalizado, mantém o estado atual
      emit(AtendimentoExecutionLoaded(
        atendimento: atendimento,
        imagemPath: atendimento.imagemPath,
        observations: atendimento.anotacoes,
      ));
    }
  } catch (e) {
    print('❌ Erro ao atualizar status: $e');
    // Em caso de erro, carrega o atendimento original
    emit(AtendimentoExecutionLoaded(
      atendimento: atendimento,
      imagemPath: atendimento.imagemPath,
      observations: atendimento.anotacoes,
    ));
  }
}

void updateImage(String imagePath) async {
  try {
    print('🔄 Cubit: Atualizando imagem no banco...');
    final currentState = state;
    if (currentState is AtendimentoExecutionLoaded) {
      // ✅ ATUALIZA O BANCO IMEDIATAMENTE
      await updateAtendimentoImagem.call(currentState.atendimento.id!, imagePath);
      
      // ✅ ATUALIZA O ESTADO LOCAL
      final updatedAtendimento = currentState.atendimento.copyWith(
        imagemPath: imagePath,
        dataAtualizacao: DateTime.now(),
      );
      
      emit(currentState.copyWith(
        imagemPath: imagePath,
        atendimento: updatedAtendimento, // ✅ IMPORTANTE: Atualiza o atendimento no estado
      ));
      
      print('✅ Cubit: Imagem atualizada no banco e no estado');
    }
  } catch (e) {
    print('❌ Cubit: Erro ao salvar imagem: $e');
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
      
     
      emit(AtendimentoExecutionLoaded(
        atendimento: atendimentoFinalizado,
        imagemPath: currentState.imagemPath,
        observations: currentState.observations,
      ));
      
      
      emit(AtendimentoExecutionSuccess());
    } catch (e) {
      print('❌ Erro: $e');
      
      emit(currentState.copyWith());
      emit(AtendimentoExecutionError(message: 'Erro ao finalizar atendimento: $e'));
    }
  }
}
}

