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

Future<int> getCurrentBitcoinBlockHeight() async {
  try {
    Response response =
    await get(Uri.parse('https://blockstream.info/api/blocks/tip/height'));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception("Getting current bitcoin block height was not successful.");
    }
  } catch (_) {
    rethrow;
  }
}