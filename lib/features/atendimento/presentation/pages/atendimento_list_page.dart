// IMPORTS COMPLETOS - verifique se tem todos:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/atendimento_list_cubit.dart';
import '../cubits/atendimento_execution_cubit.dart';
import '../../domain/entities/atendimento.dart';
import '../../data/repositories/atendimento_repository_impl.dart';
import '../../domain/usecases/update_atendimento.dart';
import '../../domain/usecases/finalizar_atendimento.dart';
import '../../domain/usecases/update_atendimento_imagem.dart';
import 'atendimento_execution_page.dart';
import 'atendimento_form_page.dart';

class AtendimentoListPage extends StatefulWidget {
  const AtendimentoListPage({Key? key}) : super(key: key);

  @override
  _AtendimentoListPageState createState() => _AtendimentoListPageState();
}

class _AtendimentoListPageState extends State<AtendimentoListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AtendimentoListCubit>().loadAtendimentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<AtendimentoListCubit, AtendimentoListState>(
        builder: (context, state) {
          if (state is AtendimentoListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AtendimentoListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AtendimentoListCubit>().loadAtendimentos();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          } else if (state is AtendimentoListLoaded) {
            final atendimentos = state.atendimentos;
            if (atendimentos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum atendimento encontrado',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Clique no botão + para criar o primeiro',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: atendimentos.length,
              itemBuilder: (context, index) {
                final atendimento = atendimentos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: _buildStatusIcon(atendimento.status),
                    title: Text(
                      atendimento.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${_statusText(atendimento.status)}'),
                        if (atendimento.anotacoes != null)
                          Text(
                            'Anotações: ${atendimento.anotacoes}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          'Criado: ${_formatDate(atendimento.dataCriacao)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        _handleMenuAction(value, atendimento, context);
                      },
                      itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                                    value: 'execute',
                                          child: Row(
                                           children: [
                                  Icon(Icons.play_arrow),
                                   SizedBox(width: 8),
                                  Text('Executar'),
                                          ],
                                        ),
                                       ), 
                        const PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('Visualizar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showAtendimentoDetails(atendimento, context);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Carregando atendimentos...'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AtendimentoFormPage()),
          ).then((_) {
            // Recarregar lista quando voltar do formulário
            context.read<AtendimentoListCubit>().loadAtendimentos();
          });
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusIcon(StatusAtendimento status) {
    switch (status) {
      case StatusAtendimento.ativo:
        return const Icon(Icons.check_circle, color: Colors.green);
      case StatusAtendimento.emAndamento:
        return const Icon(Icons.autorenew, color: Colors.orange);
      case StatusAtendimento.finalizado:
        return const Icon(Icons.done_all, color: Colors.blue);
      case StatusAtendimento.deletado:
        return const Icon(Icons.delete, color: Colors.red);
    }
  }

  String _statusText(StatusAtendimento status) {
    switch (status) {
      case StatusAtendimento.ativo:
        return 'Ativo';
      case StatusAtendimento.emAndamento:
        return 'Em Andamento';
      case StatusAtendimento.finalizado:
        return 'Finalizado';
      case StatusAtendimento.deletado:
        return 'Deletado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, Atendimento atendimento, BuildContext context) {
    switch (action) {
          case 'execute':
      _navigateToExecution(atendimento, context);
      break;
      case 'view':
        _showAtendimentoDetails(atendimento, context);
        break;
      case 'edit':
        _editAtendimento(atendimento, context);
        break;
      case 'delete':
        _showDeleteDialog(atendimento, context);
        break;
    }
  }

  void _showAtendimentoDetails(Atendimento atendimento, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalhes do Atendimento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Descrição: ${atendimento.descricao}'),
                const SizedBox(height: 8),
                Text('Status: ${_statusText(atendimento.status)}'),
                if (atendimento.anotacoes != null) ...[
                  const SizedBox(height: 8),
                  Text('Anotações: ${atendimento.anotacoes}'),
                ],
                const SizedBox(height: 8),
                Text('Criado em: ${_formatDate(atendimento.dataCriacao)}'),
                if (atendimento.dataAtualizacao != null) ...[
                  const SizedBox(height: 8),
                  Text('Atualizado em: ${_formatDate(atendimento.dataAtualizacao!)}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _editAtendimento(Atendimento atendimento, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
     builder: (context) => AtendimentoFormPage(atendimentoParaEditar: atendimento),
    ),
  ).then((_) {
    // Recarregar lista quando voltar da edição
    context.read<AtendimentoListCubit>().loadAtendimentos();
  });
}

  void _showDeleteDialog(Atendimento atendimento, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Deseja excluir o atendimento "${atendimento.descricao}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<AtendimentoListCubit>().deleteAtendimentoById(atendimento.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Atendimento excluído com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

void _navigateToExecution(Atendimento atendimento, BuildContext context) {
  Navigator.push(
    context, // ← AQUI está usando o context do parâmetro
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => AtendimentoExecutionCubit(
          updateAtendimento: UpdateAtendimento(context.read<AtendimentoRepositoryImpl>()),
          updateAtendimentoImagem: UpdateAtendimentoImagem(context.read<AtendimentoRepositoryImpl>()),
        ),
        child: AtendimentoExecutionPage(atendimento: atendimento),
      ),
    ),
  ).then((_) {
    // ⬇️⬇️⬇️ PROBLEMA: Aqui está tentando usar 'context' mas pode estar fora do escopo
    context.read<AtendimentoListCubit>().loadAtendimentos();
  });
}
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Todos'),
                onTap: () {
                  context.read<AtendimentoListCubit>().loadAtendimentos();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Ativos'),
                onTap: () {
                  context.read<AtendimentoListCubit>().filterByStatus(StatusAtendimento.ativo);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Em Andamento'),
                onTap: () {
                  context.read<AtendimentoListCubit>().filterByStatus(StatusAtendimento.emAndamento);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Finalizados'),
                onTap: () {
                  context.read<AtendimentoListCubit>().filterByStatus(StatusAtendimento.finalizado);
                  Navigator.of(context).pop();


                },
              ),
            ],
          ),
        );
      },
    );
  }
}