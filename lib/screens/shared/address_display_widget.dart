import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class AddressDisplayWidget extends ConsumerStatefulWidget {
  final String address;
  final bool isEditable;
  final VoidCallback? onEditPressed;
  final bool isLnurl;

  const AddressDisplayWidget({
    super.key,
    required this.address,
    this.isEditable = false,
    this.onEditPressed,
    this.isLnurl = false,
  });

  @override
  _AddressDisplayWidgetState createState() => _AddressDisplayWidgetState();
}

class _AddressDisplayWidgetState extends ConsumerState<AddressDisplayWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // If it's an LNURL, show a simple, non-expandable view.
    if (widget.isLnurl) {
      return _buildLnurlView();
    }

    // Otherwise, build the standard, expandable address view.
    return _buildStandardAddressView();
  }

  /// Builds the standard, expandable view for Bitcoin addresses.
  Widget _buildStandardAddressView() {
    final bool isLongAddress = widget.address.length > 30;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isLongAddress) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: _buildAddressContentView(isLongAddress),
            ),
          ),
          SizedBox(height: 4.h),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          SizedBox(height: 4.h),
          _buildActionButtonsRow(),
        ],
      ),
    );
  }

  /// Builds the simple, non-expandable view for LNURLs.
  Widget _buildLnurlView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              widget.address,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          SizedBox(height: 4.h),
          _buildActionButtonsRow(),
        ],
      ),
    );
  }

  /// Builds the row containing the Share, Copy, and Edit buttons.
  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share'.i18n,
          onTap: () {
            Share.share(widget.address);
          },
        ),
        _buildActionButton(
          icon: Icons.copy_all_outlined,
          label: 'Copy'.i18n,
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.address));
            showMessageSnackBar(
              message: 'Address copied to clipboard'.i18n,
              error: false,
              context: context,
            );
          },
        ),
        if (widget.isEditable)
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit'.i18n,
            onTap: widget.onEditPressed,
          ),
      ],
    );
  }

  /// Builds the appropriate address content view (truncated or expanded).
  Widget _buildAddressContentView(bool isLongAddress) {
    if (isLongAddress && !_isExpanded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '${widget.address.substring(0, 15)}...${widget.address.substring(widget.address.length - 15)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 24.sp),
        ],
      );
    }

    // Otherwise, show the full, styled "Bitcoin-like" view.
    final regex = RegExp('.{1,4}');
    final chunks =
    regex.allMatches(widget.address).map((m) => m.group(0)!).toList();
    final color = Colors.orange;

    final baseStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );

    final addressLength = widget.address.length;
    final highlightStartIndex = addressLength - 5;
    List<Widget> children = [];
    int currentCharIndex = 0;

    for (final chunk in chunks) {
      final chunkLength = chunk.length;
      final chunkEndIndex = currentCharIndex + chunkLength;

      if (currentCharIndex == 0) {
        // First chunk is always highlighted with primary color.
        children.add(Text(chunk, style: baseStyle.copyWith(color: color)));
      } else if (chunkEndIndex > highlightStartIndex) {
        // This chunk is at the end and needs special handling for the last 5 chars.
        final splitPoint = highlightStartIndex - currentCharIndex;
        if (splitPoint <= 0) {
          // The entire chunk is within the last 5 characters.
          children.add(Text(chunk, style: baseStyle.copyWith(color: color)));
        } else {
          // The chunk is split between normal and highlighted.
          final normalPart = chunk.substring(0, splitPoint);
          final highlightedPart = chunk.substring(splitPoint);
          children.add(RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                TextSpan(text: normalPart, style: const TextStyle(color: Colors.white)),
                TextSpan(text: highlightedPart, style: TextStyle(color: color)),
              ],
            ),
          ));
        }
      } else {
        // It's a normal middle chunk.
        children.add(Text(chunk, style: baseStyle.copyWith(color: Colors.white)));
      }
      currentCharIndex += chunkLength;
    }

    if (isLongAddress) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 24.sp),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      runSpacing: 4.h,
      children: children,
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
        required String label,
        required VoidCallback? onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white70, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: 14.sp),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }
}