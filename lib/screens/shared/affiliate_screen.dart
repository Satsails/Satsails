import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/translations/translations.dart'; // Assuming translation support

class AffiliateScreen extends ConsumerStatefulWidget {
  const AffiliateScreen({super.key});

  @override
  _AffiliateScreenState createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends ConsumerState<AffiliateScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh the user provider to ensure the latest state
    ref.refresh(userProvider);
    // Reset providers only once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendTxProvider.notifier).resetToDefault();
      ref.read(sendBlocksProvider.notifier).state = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read the affiliate code from userProvider
    final currentInsertedAffiliateCode = ref.refresh(userProvider).affiliateCode ?? '';

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme consistent with OpenPin
      appBar: AppBar(
        title: Center(
          child: Text(
            'Affiliate Code'.i18n, // Translated title
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp, // Responsive font size
            ),
          ),
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success or info icon based on affiliate code status
            currentInsertedAffiliateCode.isNotEmpty
                ? Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48.w, // Responsive size
            )
                : Icon(
              Icons.info,
              color: Colors.orange,
              size: 48.w, // Responsive size
            ),
            SizedBox(height: 20.h), // Responsive spacing
            // Styled container for the affiliate code message
            Container(
              padding: EdgeInsets.all(24.w), // Larger padding for prominence
              decoration: BoxDecoration(
                color: const Color(0xFF212121), // Dark grey background
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              constraints: BoxConstraints(maxWidth: 350.w), // Slightly larger card
              child: Text(
                currentInsertedAffiliateCode.isEmpty
                    ? 'No affiliate code inserted.'.i18n
                    : 'Affiliate code "$currentInsertedAffiliateCode" inserted successfully!'.i18n,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp, // Responsive text size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40.h), // Responsive spacing
            // Continue button styled like OpenPin's "Unlock" button
            ElevatedButton(
              onPressed: () async {
                final authModel = ref.read(authModelProvider);
                final user = ref.read(userProvider);
                final insertedAffiliateCode = user.affiliateCode ?? '';
                final hasUploadedAffiliateCode = user.hasUploadedAffiliateCode ?? false;

                final mnemonic = await authModel.getMnemonic();
                if (mnemonic != null && mnemonic.isNotEmpty) {
                  if (insertedAffiliateCode.isNotEmpty && !hasUploadedAffiliateCode) {
                    try {
                      await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
                      showMessageSnackBar(
                        message: 'Affiliate code inserted successfully'.i18n,
                        error: false,
                        context: context,
                        top: true,
                      );
                      ref.invalidate(initializeUserProvider);
                    } catch (e) {
                      // Display error message if the provider throws an error
                      showMessageSnackBar(
                        message: 'Error inserting affiliate code'.i18n,
                        error: true,
                        context: context,
                        top: true,
                      );
                    }
                  }
                  context.pushReplacement('/open_pin');
                } else {
                  context.pushReplacement('/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
              ),
              child: Text(
                'Continue'.i18n,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}