import 'package:totheblessing/models/user_model.dart';
import 'api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository({required this.apiService});

  Future<List<UserModel>> getUsers(List<String> idsList) async {
    final response = await apiService.dio.get('/user',
      queryParameters: {
        'id': idsList,
      },
    );
    List data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> createUser(UserModel user) async {
    final response = await apiService.dio.post('/user', data: user.toJson());
    final data = response.data;
    if (data != null && data['user'] != null) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Usuário não encontrado na resposta.');
    }
  }

}
