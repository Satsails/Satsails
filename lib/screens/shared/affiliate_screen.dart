import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AffiliateScreen extends ConsumerWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: const _AffiliateView(),
        ),
      ),
    );
  }
}

class _AffiliateView extends ConsumerStatefulWidget {
  const _AffiliateView();

  @override
  ConsumerState<_AffiliateView> createState() => _AffiliateViewState();
}

class _AffiliateViewState extends ConsumerState<_AffiliateView> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final enteredCode = _textController.text.trim();

    try {
      if (enteredCode.isNotEmpty) {
        final upperCaseCode = enteredCode.toUpperCase();
        await ref.read(userProvider.notifier).setAffiliateCode(upperCaseCode);

        if (mounted) {
          showMessageSnackBar(
              message: 'Affiliate code inserted successfully'.i18n,
              error: false,
              context: context,
              top: true);
        }
      }

      ref.invalidate(initializeUserProvider);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save affiliate code'.i18n;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Affiliate Program'.i18n,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text(
              'Enter a code if you were referred by someone. You can add this later in settings.'
                  .i18n,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18.sp,
                  height: 1.5)),
          SizedBox(height: 24.h),
          TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Affiliate Code'.i18n,
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              hintStyle: TextStyle(color: Colors.grey[400]),
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
              ),
            ),
          const Spacer(),
          SizedBox(height: 20.h),
          _isLoading
              ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
              : CustomButton(
            text: 'Continue'.i18n,
            onPressed: _handleContinue,
            primaryColor: Colors.green.withOpacity(0.8),
            secondaryColor: Colors.green.withOpacity(0.6),
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }
}