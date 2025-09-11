import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totheblessing/models/group_model.dart';
import 'api_service.dart';

class GroupRepository {
  final ApiService apiService;

  GroupRepository({required this.apiService});

  Future<List<GroupModel>> getGroups(List<String> idsList) async {
    final queryParams = <String, dynamic>{};

    // Para cada ID, adiciona um parâmetro 'id' repetido
    for (var id in idsList) {
      queryParams.putIfAbsent('id', () => []).add(id);
    }

    final response =
        await apiService.dio.get('/groups', queryParameters: queryParams);
    List data = response.data;
    return data.map((json) => GroupModel.fromJson(json)).toList();
  }

  Future<GroupModel> createGroup(GroupModel group) async {
    final formData = FormData();
    formData.fields
      ..add(MapEntry('name', group.name))
      ..add(MapEntry('title', group.title))
      ..add(MapEntry('members',
          group.members.join(','))); // se backend espera lista como CSV
    if (group.content != null) {
      formData.fields.add(MapEntry('content', group.content!));
    }

    if (group.imageFile != null) {
      formData.files.add(
        MapEntry(
          'imageFile',
          await MultipartFile.fromFile(group.imageFile!.path,
              filename: group.imageFile!.name),
        ),
      );
    }
    final response = await apiService.dio.post(
      '/groups',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    final data = response.data;
    if (data != null && data['group'] != null) {
      return GroupModel.fromJson(data['group']);
    } else {
      throw Exception('Usuário não encontrado na resposta.');
    }
  }

  Future<GroupModel> joinGroup(String groupId, String userId) async {
    try {
      final response = await apiService.dio.patch(
        '/groups',
        data: {
          'GroupId': groupId,
          'UserId': userId,
        },
      );

      final data = response.data;
      if (data != null) {
        return GroupModel.fromJson(data);
      } else {
        throw Exception('Usuário não encontrado na resposta.');
      }
    } catch (e) {
      throw Exception('Erro ao entrar no grupo: $e');
    }
  }

// Adicione a função abaixo na sua classe GroupRepository
Future<void> updateGroup({
  required String groupId,
  String? name,
  String? title,
  String? content,
  XFile? image, // O tipo File é do pacote dart:io
}) async {
  try {
    final formData = 
    FormData();

    // O GroupId é obrigatório, então sempre o adicionamos
    formData.fields.add(MapEntry('GroupId', groupId));

    // Adiciona os campos opcionais apenas se não forem nulos
    if (name != null) {
      formData.fields.add(MapEntry('Name', name));
    }
    if (title != null) {
      formData.fields.add(MapEntry('Title', title));
    }
    if (content != null) {
      formData.fields.add(MapEntry('Content', content));
    }

    // Adiciona a imagem, se fornecida
    if (image != null) {
      final fileName = image.path.split('/').last;
      formData.files.add(
        MapEntry(
          'Image', // O nome do campo no seu DTO é 'Image'
          await MultipartFile.fromFile(image.path, filename: fileName),
        ),
      );
    }

    // Envia a requisição PATCH
    final response = await apiService.dio.patch(
      '/groups/update',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    // Opcional: Lidar com a resposta do backend, se necessário
    if (response.statusCode == 200) {
      debugPrint('Grupo atualizado com sucesso!');
    } else {
      debugPrint('Falha ao atualizar o grupo. Status: ${response.statusCode}');
      throw Exception('Falha ao atualizar o grupo.');
    }
  } on DioException catch (e) {
    // Lidar com erros de Dio (rede, servidor, etc.)
    throw Exception('Erro de rede: ${e.message}');
  } catch (e) {
    // Lidar com outros erros
    throw Exception('Erro ao atualizar o grupo: $e');
  }
}
}
