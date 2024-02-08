import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceProvider {
  double price = 0.0;

  Future<void> fetchBitcoinPrice() async {
    final apiUrl = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('price')) {
          price = double.parse(data['price']);
        } else {
          throw Exception('Error: Response does not contain the expected "price" field.');
        }
      } else {
        throw Exception('Failed to fetch Bitcoin price. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching Bitcoin price: $error');
    }
  }
}
