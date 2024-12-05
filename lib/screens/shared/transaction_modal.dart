import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:vibration/vibration.dart';

void showFullscreenTransactionModal(BuildContext context, double amount, String successMessage) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedCheckboxWidget(
              amount: amount,
              successMessage: successMessage,
            ),
          ),
        ),
      );
    },
  );
}

class AnimatedCheckboxWidget extends ConsumerStatefulWidget {
  final double amount;
  final String successMessage;

  const AnimatedCheckboxWidget({
    Key? key,
    required this.amount,
    required this.successMessage,
  }) : super(key: key);

  @override
  _AnimatedCheckboxWidgetState createState() => _AnimatedCheckboxWidgetState();
}

class _AnimatedCheckboxWidgetState extends ConsumerState<AnimatedCheckboxWidget> {
  bool checked = false;

  @override
  void initState() {
    super.initState();

    // Delay the checkbox animation and vibration
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        checked = true;

        // Vibrate when the checkbox is checked
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 100);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MSHCheckbox(
          size: 100,
          value: checked,
          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
            checkedColor: Colors.green,
            uncheckedColor: Colors.white,
            disabledColor: Colors.grey,
          ),
          style: MSHCheckboxStyle.stroke,
          duration: const Duration(milliseconds: 500),
          onChanged: (_) {
            // Do nothing when the checkbox is tapped
          },
        ),
        const SizedBox(height: 10),
        Text(
          "${widget.amount}",
          style: const TextStyle(
            fontSize: 48,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.successMessage,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
