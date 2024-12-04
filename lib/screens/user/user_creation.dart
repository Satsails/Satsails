import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class UserCreation extends ConsumerWidget {
  const UserCreation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'User Section'.i18n(ref),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome,'.i18n(ref),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'This section is completely anonymous and does not require any personal information.'.i18n(ref),
                  style: TextStyle(color: Colors.grey[300], fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomElevatedButton(
                  text: 'Create anonymous account'.i18n(ref),
                  onPressed: () async {
                    ref.read(loadingProvider.notifier).state = true;
                    try {
                      await ref.watch(createUserProvider.future);
                      showMessageSnackBar(
                        message: 'Anonymous account created successfully!'.i18n(ref),
                        error: false,
                        context: context,
                      );
                      ref.read(loadingProvider.notifier).state = false;
                      context.go('/pix_onboarding');
                    } catch (e) {
                      ref.read(loadingProvider.notifier).state = false;
                      showMessageSnackBar(
                        message: 'There was an error saving your code. Please try again or contact support'.i18n(ref),
                        error: true,
                        context: context,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // De-emphasized Recover Account section
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 20,
                            right: 20,
                            top: 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Recover your legacy account'.i18n(ref),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Enter recovery code'.i18n(ref),
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomElevatedButton(
                                  text: 'Recover'.i18n(ref),
                                  onPressed: () async {
                                    ref.read(loadingProvider.notifier).state = true;
                                    try {
                                      await ref.read(userProvider.notifier).setRecoveryCode(controller.text);
                                      await ref.read(setUserProvider.future);
                                      ref.read(loadingProvider.notifier).state = false;
                                      context.go('/pix_onboarding');
                                      showMessageSnackBar(
                                        message: 'Account recovered successfully!'.i18n(ref),
                                        error: false,
                                        context: context,
                                      );
                                    } catch (e) {
                                      ref.read(loadingProvider.notifier).state = false;
                                      await ref.read(userProvider.notifier).setRecoveryCode('');
                                      showMessageSnackBar(
                                        message: 'The code you have inserted is not correct'.i18n(ref),
                                        error: true,
                                        context: context,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Legacy: Recover Account'.i18n(ref),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
            if (isLoading)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.orange,
                    size: 50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}