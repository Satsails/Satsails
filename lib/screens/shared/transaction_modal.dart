import 'dart:async';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        // Animated MSHCheckbox
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
          "Value",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "R\$ ${widget.amount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
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
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Concluir" Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Details" Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(
                    "Details".i18n(ref),
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
