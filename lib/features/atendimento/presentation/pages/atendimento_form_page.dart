import 'package:aplicativo/features/atendimento/domain/entities/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/atendimento_form_cubit.dart';


class AtendimentoFormPage extends StatefulWidget {
  final Atendimento? atendimentoParaEditar;

  const AtendimentoFormPage({Key? key, this.atendimentoParaEditar}) : super(key: key);

  @override
  _AtendimentoFormPageState createState() => _AtendimentoFormPageState();
}

class _AtendimentoFormPageState extends State<AtendimentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _anotacoesController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Atendimento'),
        backgroundColor: Colors.brown,
      ),
      body: BlocListener<AtendimentoFormCubit, AtendimentoFormState>(
        listener: (context, state) {
          if (state is AtendimentoFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Atendimento criado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is AtendimentoFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Atendimento*',
                    border: OutlineInputBorder(),
                    hintText: 'Descreva o atendimento...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    if (value.length < 5) {
                      return 'A descrição deve ter pelo menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _anotacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Anotações (opcional)',
                    border: OutlineInputBorder(),
                    hintText: 'Observações adicionais...',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 30),
                BlocBuilder<AtendimentoFormCubit, AtendimentoFormState>(
                  builder: (context, state) {
                    if (state is AtendimentoFormSaving) {
                      return const CircularProgressIndicator();
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AtendimentoFormCubit>().saveAtendimento(
                               descricao: _descricaoController.text,
                             anotacoes: _anotacoesController.text.isEmpty ? null : _anotacoesController.text,
                                    );
                            
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Criar Atendimento',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}