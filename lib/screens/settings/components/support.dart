import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Support extends ConsumerStatefulWidget {
  const Support({super.key});

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends ConsumerState<Support> {
  late CrispConfig config;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);

    config = CrispConfig(
      websiteID: "a6d4fc8d-ff0a-45dd-b97e-1c76adac35c1",
      user: User(
        nickName: user.paymentId,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCrispChat(ref);
    });
  }

  Future<void> _openCrispChat(WidgetRef ref) async {
    try {
      await FlutterCrispChat.openCrispChat(config: config);
      final user = ref.read(userProvider);
      FlutterCrispChat.setSessionString(
        key: "payment_id",
        value: user.paymentId,
      );
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Support'.i18n, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  text: 'Open support chat'.i18n,
                  onPressed: () async {
                    await _openCrispChat(ref);
                  },
                  backgroundColor: Colors.orange,
                  textColor: Colors.black
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  text: 'Reset Chat Session'.i18n,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                  onPressed: () async {
                    await FlutterCrispChat.resetCrispChatSession();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
