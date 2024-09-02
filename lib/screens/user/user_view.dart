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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black app bar
        title: const Text('User Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ),
      backgroundColor: Colors.black, // Black background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPaymentIdRow(user.paymentId),
              const SizedBox(height: 16.0),
              _buildAffiliateCodeRow(user.affiliateCode?.isNotEmpty == true ? user.affiliateCode! : 'N/A'),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Inserted Affiliate', user.hasInsertedAffiliate ? 'Yes' : 'No'),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Created Affiliate', user.hasCreatedAffiliate ? 'Yes' : 'No'),
              const SizedBox(height: 16.0),
              _buildRecoveryCodeRow(user.recoveryCode),
              const SizedBox(height: 24.0),
              Text(
                'Hint: Please store your recovery code somewhere safe. There is no other way to recover your account if you lose this code.',
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              CustomElevatedButton(
                onPressed: () {
                  // Navigate to affiliate section
                  Navigator.of(context).pushNamed('/affiliate');
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

  Widget _buildUserDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentIdRow(String paymentId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Payment ID',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Text(
            paymentId,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: Colors.white),
          onPressed: () {
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
        ),
      ],
    );
  }

  Widget _buildAffiliateCodeRow(String affiliateCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Affiliate Code',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Text(
            affiliateCode,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        if (affiliateCode != 'N/A')
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: affiliateCode));
              Fluttertoast.showToast(
                msg: 'Affiliate Code copied to clipboard',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.01,
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecoveryCodeRow(String recoveryCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recovery Code',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Text(
            _isRecoveryCodeHidden ? '************' : recoveryCode,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
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
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
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
            },
          ),
      ],
    );
  }
}
