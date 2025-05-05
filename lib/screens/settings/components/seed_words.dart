import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeedWords extends ConsumerWidget {
  const SeedWords({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authModel = ref.read(authModelProvider);
    final mnemonicFuture = authModel.getMnemonic();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Seed Words'.i18n,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.sp),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: FutureBuilder<String?>(
        future: mnemonicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            List<String> words = snapshot.data!.split(' ');
            final backupDone = ref.watch(settingsProvider).backup;

            return Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Generate 4 rows of 3 seed words each
                          for (int rowIndex = 0; rowIndex < 4; rowIndex++) ...[
                            // Add vertical spacing before every row except the first
                            if (rowIndex > 0) SizedBox(height: 16.h),
                            Row(
                              children: [
                                for (int colIndex = 0; colIndex < 3; colIndex++) ...[
                                  Expanded(
                                    child: Container(
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0x333333).withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: const Color(0xFF6D6D6D),
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${rowIndex * 3 + colIndex + 1}.',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              words[rowIndex * 3 + colIndex],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Add horizontal spacing between containers within a row
                                  if (colIndex < 2) SizedBox(width: 16.w),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.w,
                      vertical: 16.h,
                    ),
                    child: backupDone
                        ? CustomButton(
                      text: 'Backup completed'.i18n,
                      onPressed: () {},
                      primaryColor: Colors.green,
                      secondaryColor: Colors.green,
                      textColor: Colors.black,
                    )
                        : CustomButton(
                      text: 'Backup Wallet'.i18n,
                      onPressed: () {
                        context.push('/backup_wallet');
                      },
                      primaryColor: Colors.green,
                      secondaryColor: Colors.green,
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'No seed words available',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }
        },
      ),
    );
  }
}