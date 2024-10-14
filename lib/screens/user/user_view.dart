import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart'; // To use Clipboard

class UserView extends ConsumerStatefulWidget {
  const UserView({super.key});

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends ConsumerState<UserView> {
  bool _isRecoveryCodeHidden = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final affiliate = ref.watch(affiliateProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('User Details'.i18n(ref), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (affiliate.createdAffiliateCode.isNotEmpty == true) ... [
                _buildCreatedAffiliateRow(affiliate.createdAffiliateCode, width, height),
                SizedBox(height: height * 0.02),
              ],
              if (affiliate.insertedAffiliateCode.isNotEmpty == true) ... [
                _buildInsertedAffiliateRow(affiliate.insertedAffiliateCode, width, height),
                SizedBox(height: height * 0.02),
              ],
              _buildRecoveryCodeSection(user.recoveryCode, width, height),
              SizedBox(height: height * 0.03),
              Text(
                'Hint: Please store your recovery code somewhere safe. There is no other way to recover your account if you lose this code.'.i18n(ref),
                style: TextStyle(color: Colors.redAccent, fontSize: width * 0.03),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.03),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white54),
                ),
                child: Column(
                  children: [
                    Text(
                      'Affiliate Portal'.i18n(ref),
                      style: TextStyle(color: Colors.white, fontSize: width * 0.045, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Track your performance and access exclusive resources.'.i18n(ref),
                      style: TextStyle(color: Colors.white70, fontSize: width * 0.035),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.02),
                    CustomElevatedButton(
                      onPressed: () {
                        context.push('/start_affiliate');
                      },
                      text: "Go to Affiliate Portal".i18n(ref),
                      backgroundColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatedAffiliateRow(String affiliateCode, double width, double height) {
    return GestureDetector(
      onTap: () {
        if (affiliateCode != 'N/A') {
          Clipboard.setData(ClipboardData(text: affiliateCode));
          Fluttertoast.showToast(
            msg: 'Created Affiliate Code copied to clipboard'.i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: height * 0.02,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Affiliate code for sharing'.i18n(ref),
            style: TextStyle(color: Colors.grey, fontSize: width * 0.04),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              Text(
                affiliateCode,
                style: TextStyle(color: Colors.white, fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: width * 0.02),
              if (affiliateCode != 'N/A')
              Icon(
                Icons.copy,
                color: Colors.white,
                size: width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsertedAffiliateRow(String affiliateCode, double width, double height) {
    return GestureDetector(
      onTap: () {
        if (affiliateCode != 'N/A') {
          Clipboard.setData(ClipboardData(text: affiliateCode));
          Fluttertoast.showToast(
            msg: 'Inserted Affiliate Code copied to clipboard'.i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: height * 0.02,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referred by'.i18n(ref),
            style: TextStyle(color: Colors.grey, fontSize: width * 0.04),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              Text(
                affiliateCode,
                style: TextStyle(color: Colors.white, fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: width * 0.02),
              if (affiliateCode != 'N/A')
              Icon(
                Icons.copy,
                color: Colors.white,
                size: width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCodeSection(String recoveryCode, double width, double height) {
    return GestureDetector(
      onTap: () {
        if (!_isRecoveryCodeHidden) {
          Clipboard.setData(ClipboardData(text: recoveryCode));
          Fluttertoast.showToast(
            msg: 'Recovery code copied to clipboard'.i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: height * 0.02,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery Code'.i18n(ref),
            style: TextStyle(color: Colors.grey, fontSize: width * 0.04),
          ),
          SizedBox(height: height * 0.01),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isRecoveryCodeHidden ? '************' : recoveryCode,
                  style: TextStyle(color: Colors.white, fontSize: width * 0.05, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isRecoveryCodeHidden ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isRecoveryCodeHidden = !_isRecoveryCodeHidden;
                  });
                },
              ),
              if (!_isRecoveryCodeHidden)
              IconButton(
                icon: Icon(Icons.copy, color: Colors.white),
                onPressed: () {
                    Clipboard.setData(ClipboardData(text: recoveryCode));
                    Fluttertoast.showToast(
                      msg: 'Recovery code copied to clipboard'.i18n(ref),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: height * 0.02,
                    );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

