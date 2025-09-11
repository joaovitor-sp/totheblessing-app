import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totheblessing/data/local_storage/group_data.dart';
import 'package:totheblessing/models/group_model.dart';
import 'package:totheblessing/presentation/pages/create_group/create_group_controller.dart';
import 'package:totheblessing/providers/data_provider.dart';
import 'package:totheblessing/providers/api_provider.dart';

class EditGroupPage extends ConsumerStatefulWidget {
  const EditGroupPage({super.key});

  @override
  ConsumerState<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends ConsumerState<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    final group = ref.read(activeGroupProvider)!;
    _nameController = TextEditingController(text: group.name);
    _titleController = TextEditingController(text: group.title);
    _contentController = TextEditingController(text: group.content ?? '');
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final group = ref.read(activeGroupProvider)!;

    GroupModel updatedGroup = GroupModel(
      id: group.id,
      name: _nameController.text,
      title: _titleController.text,
      content: _contentController.text,
      imageFile: _pickedImage, // envia o arquivo para o backend
      imageUrl: group.imageUrl,
      members: group.members,
      createdAt: group.createdAt,
    );

    try {
      // Chamada para atualizar o grupo no backend
      await ref.read(groupRepositoryProvider).updateGroup(groupId: group.id!, name: updatedGroup.name, title: updatedGroup.title, content: updatedGroup.content, image: updatedGroup.imageFile);
      final List<GroupModel> updateGroup = await ref.read(groupRepositoryProvider).getGroups([group.id!]);
      ref.read(createGroupControllerProvider).saveGroup(updateGroup[0]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar grupo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.read(activeGroupProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Grupo"),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagem do grupo
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: _pickedImage != null
                          ? DecorationImage(
                              image: FileImage(File(_pickedImage!.path)),
                              fit: BoxFit.cover,
                            )
                          : (group.imageUrl != null && group.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(group.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                      "assets/images/default_calendar_image.png"),
                                  fit: BoxFit.cover,
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nome do grupo
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Grupo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Conteúdo
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 24),

                // Botão de salvar
                ElevatedButton(
                  onPressed: _saveGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
