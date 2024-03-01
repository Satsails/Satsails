import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getLightningInvoice(String invoice, String publicKey) async {
  final endpoint = 'https://api.boltz.exchange';

  Map<String, dynamic> requestBody = {
    'invoice': invoice,
    'to': 'BTC',
    'from': 'BTC',
    'refundPublicKey': publicKey,
  };

  try {
    var createdResponse = await http.post(
      Uri.parse('$endpoint/v2/swap/submarine'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (createdResponse.statusCode == 200) {
      var responseData = json.decode(createdResponse.body);
      print('Created swap');
      print(responseData);
      // Access other properties of the created swap if needed
    } else {
      print('Failed to create swap with status: ${createdResponse.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

// Example usage:
// await createSubmarineSwap('your_invoice_here', 'your_public_key_here');
