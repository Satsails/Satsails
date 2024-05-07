import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SideswapUploadData {
  Future<void> uploadInputs(
      Map<String, dynamic> params,
      String returnAddress,
      Map<String, dynamic> inputs,
      Map<String, dynamic> receiveAddress,
      ) async {
    try {
      final result = params["result"];
      final endpoint = result["upload_url"];
      final Map<String, dynamic> requestData = {
        "id": 1,
        "method": "swap_start",
        "params": {
          "change_addr": returnAddress,
          "inputs": inputs["utxos"],
          "order_id": result["order_id"],
          "recv_addr": receiveAddress["address"],
          "recv_amount": result["recv_amount"],
          "recv_asset": result["recv_asset"],
          "send_amount": result["send_amount"],
          "send_asset": result["send_asset"],
        },
      };

      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // walletStrategy.signInputs(responseData, result["order_id"], uri, result["send_asset"]);

      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> signInputs(String data, String orderId, String submitId, Uri uri) async {
    final Map<String, dynamic> requestData = {
      "id": 1,
      "method": "swap_sign",
      "params": {
        "order_id": orderId,
        "submit_id": submitId,
        "pset": data,
      },
    };

    http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    ).then((response) {
      if (response.statusCode == 200) {
        print('Sign inputs response: ${response.body}');
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    });
  }
}
