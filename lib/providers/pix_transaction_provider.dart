import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../screens/charge/components/pix_buttons.dart';

final PixTransactionReceivedProvider = StateProvider.family<String?, String>((ref, appId) {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://your-rails-server/cable?app_id=$appId'),
  );

  channel.stream.listen((event) {
    if (event == 'pix received') {
      ref.read(topSelectedButtonProvider.notifier).state = "Check Pix Transactions";
    }
  });

  return "Waiting for transactions...";
});
