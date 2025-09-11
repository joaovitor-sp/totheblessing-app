import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totheblessing/models/user_model.dart';
import 'package:totheblessing/presentation/pages/create_group/create_group_controller.dart';
import 'package:totheblessing/presentation/pages/login/login_controller.dart';
import 'package:totheblessing/providers/data_provider.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => CreateGroupPageState();
}
class CreateGroupPageState extends ConsumerState<CreateGroupPage> {
      final TextEditingController _nameController = TextEditingController();
      final TextEditingController _titleController = TextEditingController();
      final TextEditingController _descriptionController = TextEditingController();

      XFile? _selectedImage;
      final ImagePicker _picker = ImagePicker();
      Future<void> _pickImage() async {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
        }
      }

      // Função para criar grupo
  void _createGroup() async {
    final String name = _nameController.text.trim();
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e selecione uma imagem')),
      );
      return;
    }

    final CreateGroupController controller = ref.read(createGroupControllerProvider);
    final UserModel? user = ref.watch(activeUserProvider);
    if (user == null || user.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar grupo')),
      );
      return;
    }
    final String userId = user.id;
    controller.createGroup(title: title, name: name, content: description, members: [userId], image: _selectedImage);
  }

   @override
   Widget build(BuildContext context) {

       return Scaffold(
      appBar: AppBar(title: const Text('Criar Grupo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Grupo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage == null
                  ? Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 50),
                    )
                  : Image.file(File(_selectedImage!.path), height: 150),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              child: const Text('Criar Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}