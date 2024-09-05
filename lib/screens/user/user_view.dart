import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart'; // To use Clipboard

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
        title: const Text('User Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPaymentIdRow(user.paymentId, width, height),
              SizedBox(height: height * 0.02),
              _buildCreatedAffiliateRow(affiliate.createdAffiliateCode.isNotEmpty == true ? affiliate.createdAffiliateCode : 'N/A'),
              SizedBox(height: height * 0.02),
              _buildInsertedAffiliateRow(affiliate.insertedAffiliateCode.isNotEmpty == true ? affiliate.insertedAffiliateCode : 'N/A'),
              SizedBox(height: height * 0.02),
              _buildRecoveryCodeRow(user.recoveryCode),
              SizedBox(height: height * 0.02),
               Text(
                'Hint: Please store your recovery code somewhere safe. There is no other way to recover your account if you lose this code.',
                style: TextStyle(color: Colors.redAccent, fontSize: width * 0.03),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              CustomElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/start_affiliate');
                },
                text: "Go to Affiliate Section",
                backgroundColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentIdRow(String paymentId, double width, double height) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: paymentId));
        Fluttertoast.showToast(
          msg: 'Payment ID copied to clipboard',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.01,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Payment ID',
            style: TextStyle(color: Colors.grey, fontSize: width * 0.04),
          ),
          Expanded(
            child: Text(
              paymentId,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedAffiliateRow(String affiliateCode) {
    return GestureDetector(
      onTap: () {
        if (affiliateCode != 'N/A') {
          Clipboard.setData(ClipboardData(text: affiliateCode));
          Fluttertoast.showToast(
            msg: 'Created Affiliate Code copied to clipboard',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: MediaQuery.of(context).size.height * 0.01,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Created Affiliate Code',
            style: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.width * 0.04),
          ),
          Expanded(
            child: Text(
              affiliateCode,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsertedAffiliateRow(String affiliateCode) {
    return GestureDetector(
      onTap: () {
        if (affiliateCode != 'N/A') {
          Clipboard.setData(ClipboardData(text: affiliateCode));
          Fluttertoast.showToast(
            msg: 'Inserted Affiliate Code copied to clipboard',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: MediaQuery.of(context).size.height * 0.01,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inserted Affiliate Code',
            style: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.width * 0.04),
          ),
          Expanded(
            child: Text(
              affiliateCode,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCodeRow(String recoveryCode) {
    return GestureDetector(
      onTap: () {
        if (!_isRecoveryCodeHidden) {
          Clipboard.setData(ClipboardData(text: recoveryCode));
          Fluttertoast.showToast(
            msg: 'Recovery code copied to clipboard',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: MediaQuery.of(context).size.height * 0.01,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recovery Code',
            style: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.width * 0.04),
          ),
          Expanded(
            child: Text(
              _isRecoveryCodeHidden ? '************' : recoveryCode,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04),
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
        ],
      ),
    );
  }
}

