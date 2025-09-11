import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'dart:io';

import 'package:totheblessing/presentation/pages/post/post_controller.dart';
import 'package:totheblessing/presentation/widgets/month_view.dart';
import 'package:totheblessing/providers/api_provider.dart';
import 'package:totheblessing/providers/data_provider.dart';

final postControllerProvider = Provider<PostController>((ref) {
  final postRepository = ref.read(postRepositoryProvider);
  return PostController(postRepository: postRepository);
});

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  PostPageState createState() => PostPageState();
}

class PostPageState extends ConsumerState<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Variável para armazenar o arquivo de mídia selecionado
  XFile? _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCreatePost() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(postControllerProvider);

    // Monta a data/hora da atividade juntando _selectedDate e _selectedTime
    final activityDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final user = ref.read(activeUserProvider);
    final group = ref.read(activeGroupProvider);
    if (user != null && group != null) {
      await controller.createPost(
        title: _titleController.text,
        content: _descriptionController.text,
        imageFile: _selectedMedia,
        activityDate: activityDate,
        groups: [group.id],
        authorId: user.id,
      );

      // Invalidate the provider with the specific parameters
      final params = PostsMapParams(
        groupId: group.id!,
        userId: user.id,
        year: activityDate.year,
        month: activityDate.month,
      );

      // Invalidate the specific provider instance
      ref.invalidate(postsMapProvider(params));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      Navigator.popAndPushNamed(
        context,
        AppRoutes.home,
      );
    });
  }

  // Manteve a função _pickMedia que aceita ImageSource
  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? media =
          await _picker.pickImage(source: source, imageQuality: 80);

      if (!mounted) return;
      if (media != null) {
        setState(() {
          _selectedMedia = media;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Mídia selecionada: ${media.path.split('/').last}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleção de mídia cancelada.')),
        );
      }
    } catch (e) {
      print('Erro ao selecionar mídia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar mídia: $e')),
      );
    }
  }

  // NOVA FUNÇÃO: Para mostrar o bottom sheet com as opções
  void _showMediaSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context); // Fecha o bottom sheet
                  _pickMedia(ImageSource.camera); // Chama a câmera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context); // Fecha o bottom sheet
                  _pickMedia(ImageSource.gallery); // Chama a galeria
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Selecione o Dia',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Selecione a Hora de Início',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Função para construir a prévia da mídia baseada em _selectedMedia
  Widget _buildMediaPreview() {
    if (_selectedMedia == null) {
      return Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.photo_outlined, color: Colors.grey),
      );
    } else {
      // Exibe a imagem selecionada usando Image.file
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_selectedMedia!.path), // Converte XFile.path para File
          width: 80,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 80,
            height: 50,
            color: Colors.red[100],
            alignment: Alignment.center,
            child: const Icon(Icons.error_outline, color: Colors.red),
          ),
        ),
      );
    }
  }

  void _publishCheckIn() {
    print('Título: ${_titleController.text}');
    print('Descrição: ${_descriptionController.text}');
    print('Data: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');
    print('Hora: ${_selectedTime.format(context)}');
    print('Mídia selecionada: ${_selectedMedia?.path ?? "Nenhuma"}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicar clicado! Dados no console.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBackgroundColor = Color(0xFFEEE8D8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo momento'),
        backgroundColor: Colors.brown[300],
        actions: [
          TextButton(
            onPressed: _onCreatePost,
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 255, 234, 0),
            ),
            child: const Text(
              'Publicar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: pageBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // <-- chave do Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título com validação
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O título é obrigatório';
                  }
                  if (value.length < 3) {
                    return 'O título deve ter no mínimo 3 letras';
                  }
                  if (value.length > 100) {
                    return 'O título deve ter no máximo 100 letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Descrição (opcional)
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              // Restante da UI (data, hora, mídia) permanece igual
              const SizedBox(height: 24.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dia',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate)),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora de início',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_selectedTime.format(context)),
                                const Icon(Icons.access_time, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showMediaSourceSelection,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar mídia'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  _buildMediaPreview(),
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
