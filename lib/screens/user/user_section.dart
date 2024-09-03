import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/charge/charge.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserCreation extends ConsumerWidget {
  const UserCreation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'User Section',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'This section is completely anonymous and does not require any personal information.',
              style: TextStyle(color: Colors.grey[300], fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            CustomElevatedButton(
              text: 'Create annonymous account',
              onPressed: () async {
                try {
                  await ref.watch(createUserProvider.future);
                  Fluttertoast.showToast(
                    msg: 'Anonymous account created successfully!'.i18n(ref),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  if(ref.watch(onBoardingInProgressProvider.notifier).state) {
                    ref.read(onBoardingInProgressProvider.notifier).state = false;
                    Navigator.pushNamed(context, '/pix_onboarding');
                  } else {
                    Navigator.pushNamed(context, '/user_view');
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'There was an error saving your code. Please try again or contact support'.i18n(ref),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              text: 'Recover account',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding when the keyboard is visible
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Recover Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            style: TextStyle(color: Colors.white),
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Enter recovery code',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomElevatedButton(
                            text: 'Recover',
                            onPressed: () async {
                              try {
                                await ref.read(userProvider.notifier).setRecoveryCode(controller.text);
                                await ref.read(setUserProvider.future);
                                Navigator.pushReplacementNamed(context, '/user_view');
                                Fluttertoast.showToast(
                                  msg: 'Account recovered successfully!'.i18n(ref),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              } catch (e) {
                                Fluttertoast.showToast(
                                  msg: 'The code you have inserted is not correct'.i18n(ref),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
