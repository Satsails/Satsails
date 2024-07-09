import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final createUserProvider = Provider((ref) => CreateUserService());

class CreateUserService {
  Future<void> sendPostRequest(String paymentId, String liquidAddress) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/post'),
      body: {
        'user': {
          'payment_id': paymentId,
          'liquid_address': liquidAddress,
        }
      },
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      response.statusCode;
    } else {
      throw Exception('Failed to create user');
    }
  }
}
