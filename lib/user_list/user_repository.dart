import 'dart:convert';
import 'package:http/http.dart' as http;

class UserRepository {
  final http.Client httpClient;

  UserRepository({
    required this.httpClient,
  });

  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('https://api.github.com/users?since=0&per_page=30');
    await Future.delayed(Duration(seconds: 5));
    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> newUsers = json.decode(response.body);
      try {
        return newUsers;
      } catch (e) {
        print('Error caching users: $e');
        return newUsers;
      }
    } else {
      throw Exception('Failed to load users');
    }
  }
}

