import 'package:http/http.dart';

Future<int> getCurrentBlockHeight() async {
  try {
    Response response =
    await get(Uri.parse('https://blockstream.info/liquid/api/blocks/tip/height'));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception("Getting current block height was not successful.");
    }
  } catch (_) {
    rethrow;
  }
}