import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../cubits/atendimento_execution_cubit.dart';
import '../../domain/entities/atendimento.dart';

class AtendimentoExecutionPage extends StatefulWidget {
  final Atendimento atendimento;

  const AtendimentoExecutionPage({
    Key? key,
    required this.atendimento,
  }) : super(key: key);

  @override
  _AtendimentoExecutionPageState createState() => _AtendimentoExecutionPageState();
}

class _AtendimentoExecutionPageState extends State<AtendimentoExecutionPage> {
  final TextEditingController _observationsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _observationsController.text = widget.atendimento.anotacoes ?? '';
    
    // Carregar imagem existente se houver
    if (widget.atendimento.imagemPath != null) {
      _selectedImage = File(widget.atendimento.imagemPath!);
    }
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Atualizar no cubit
        context.read<AtendimentoExecutionCubit>().updateImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Atualizar no cubit
        context.read<AtendimentoExecutionCubit>().updateImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateObservations(String observations) {
    context.read<AtendimentoExecutionCubit>().updateObservations(observations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executar Atendimento'),
        backgroundColor: Colors.brown,
        actions: [
          BlocBuilder<AtendimentoExecutionCubit, AtendimentoExecutionState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  context.read<AtendimentoExecutionCubit>().saveAtendimento();
                },
                tooltip: 'Salvar Alterações',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AtendimentoExecutionCubit, AtendimentoExecutionState>(
        listener: (context, state) {
          if (state is AtendimentoExecutionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Atendimento salvo com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is AtendimentoExecutionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AtendimentoExecutionSaving) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações do Atendimento
                _buildAtendimentoInfo(),
                
                const SizedBox(height: 24),
                
                // Seção de Imagem
                _buildImageSection(),
                
                const SizedBox(height: 24),
                
                // Campo de Observações
                _buildObservationsSection(),
                
                const SizedBox(height: 32),
                
                // Botão Finalizar
                if (widget.atendimento.status != StatusAtendimento.finalizado)
                  _buildFinalizeButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAtendimentoInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ATENDIMENTO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.atendimento.descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: _getStatusColor(widget.atendimento.status),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${_getStatusText(widget.atendimento.status)}',
                  style: TextStyle(
                    color: _getStatusColor(widget.atendimento.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Criado em: ${_formatDate(widget.atendimento.dataCriacao)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVIDÊNCIA FOTOGRÁFICA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 12),
        
        // Preview da Imagem
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Erro ao carregar imagem',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma imagem capturada',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
        ),
        
        const SizedBox(height: 16),
        
        // Botões de Captura
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _captureImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('CÂMERA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('GALERIA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSERVAÇÕES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _observationsController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Descreva as observações do atendimento, trabalho realizado, materiais utilizados...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
          onChanged: _updateObservations,
        ),
      ],
    );
  }

  Widget _buildFinalizeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<AtendimentoExecutionCubit>().finalizeAtendimento();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'FINALIZAR ATENDIMENTO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getStatusText(StatusAtendimento status) {
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

  Color _getStatusColor(StatusAtendimento status) {
    switch (status) {
      case StatusAtendimento.ativo:
        return Colors.green;
      case StatusAtendimento.emAndamento:
        return Colors.orange;
      case StatusAtendimento.finalizado:
        return Colors.blue;
      case StatusAtendimento.deletado:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}