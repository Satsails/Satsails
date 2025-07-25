
import 'package:Satsails/models/breez/sdk_instance.dart';

Future<void> registerWebhook() async {
  // ANCHOR: register-webook
  await breezSDKLiquid.instance!
      .registerWebhook(webhookUrl: "https://your-nds-service.com/api/v1/notify?platform=ios&token=<PUSH_TOKEN>");
  // ANCHOR_END: register-webook
}

Future<void> unregisterWebhook() async {
  // ANCHOR: unregister-webook
  await breezSDKLiquid.instance!.unregisterWebhook();
  // ANCHOR_END: unregister-webook
}
