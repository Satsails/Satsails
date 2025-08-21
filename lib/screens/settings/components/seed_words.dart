import 'dart:ui'; // Required for BackdropFilter
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart'; // Ensure this import is present
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeedWords extends ConsumerStatefulWidget {
  const SeedWords({super.key});

  @override
  _SeedWordsState createState() => _SeedWordsState();
}

class _SeedWordsState extends ConsumerState<SeedWords> {
  String? _mnemonic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure ref is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMnemonic();
    });
  }

  Future<void> _fetchMnemonic() async {
    final authModel = ref.read(authModelProvider);
    final mnemonicData = await authModel.getMnemonic();

    if (mounted) {
      if (mnemonicData != null && mnemonicData.isNotEmpty) {
        setState(() {
          _mnemonic = mnemonicData;
          _isLoading = false;
        });
      } else {
        // Handle error case, e.g., show a snackbar and pop
        showMessageSnackBar(
          context: context,
          message: 'Failed to load seed words.'.i18n,
          error: true,
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backupDone = ref.watch(settingsProvider).backup;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Seed Words'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy, color: Colors.white, size: 22.sp),
            onPressed: () async {
              if (_mnemonic != null) {
                await Clipboard.setData(ClipboardData(text: _mnemonic!));
                // Correctly call showMessageSnackBar with error: false
                showMessageSnackBar(
                  context: context,
                  message: 'Seed words copied to clipboard'.i18n,
                  error: false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.key_outlined,
                                size: 40.sp,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Your Secret Phrase'.i18n,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: _mnemonic!.split(' ').length,
                                itemBuilder: (context, index) {
                                  final words = _mnemonic!.split(' ');
                                  return _buildWordTile(
                                      index + 1, words[index]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: backupDone
                    ? CustomButton(
                  text: 'Backup Completed'.i18n,
                  onPressed: () {},
                  primaryColor: Colors.green.withOpacity(0.8),
                  secondaryColor: Colors.green.withOpacity(0.6),
                  textColor: Colors.white,
                )
                    : CustomButton(
                  text: 'Backup Wallet'.i18n,
                  onPressed: () {
                    context.push('/backup_wallet');
                  },
                  primaryColor: Colors.white.withOpacity(0.2),
                  secondaryColor: Colors.white.withOpacity(0.15),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordTile(int index, String word) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$index.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              word,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
