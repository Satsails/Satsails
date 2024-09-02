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
                    msg: 'Annymous account created successfully!'.i18n(ref),
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
                // Add your onPressed code here!
              },
            ),
          ],
        ),
      ),
    );
  }
}
