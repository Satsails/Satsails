import 'package:Satsails/translations/translations.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';

final today = DateUtils.dateOnly(DateTime.now());

class Calendar extends ConsumerWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildCalendarDialogButton(context, ref);
  }

  _buildCalendarDialogButton(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    const dayTextStyle =
    TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
    final anniversaryTextStyle = TextStyle(
      color: Colors.red[400],
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    final config = CalendarDatePicker2WithActionButtonsConfig(
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Colors.orangeAccent,
      closeDialogOnCancelTapped: true,
      calendarViewMode: DatePickerMode.day,
      firstDayOfWeek: 1,
      weekdayLabelTextStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: screenWidth * 0.03, // 3% of screen width
      ),
      controlsTextStyle: TextStyle(
        color: Colors.black,
        fontSize: screenWidth * 0.03, // 3% of screen width
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white, fontSize: screenWidth * 0.03),
      dayTextStylePredicate: ({required date}) {
        TextStyle? textStyle;
        if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
          textStyle = anniversaryTextStyle;
        }
        return textStyle;
      },
      dayBuilder: ({
        required date,
        textStyle,
        decoration,
        isSelected,
        isDisabled,
        isToday,
      }) {
        Widget? dayWidget;
        if (isToday == true) {
          dayWidget = Container(
            decoration: decoration,
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatDecimal(date.day),
                    style: textStyle,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Container(
                      height: screenWidth * 0.01,
                      width: screenWidth * 0.01,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.01),
                        color: isSelected == true
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return dayWidget;
      },
      yearBuilder: ({
        required year,
        decoration,
        isCurrentYear,
        isDisabled,
        isSelected,
        textStyle,
      }) {
        return Center(
          child: Container(
            decoration: decoration,
            height: screenWidth * 0.09, // 9% of screen width
            width: screenWidth * 0.18, // 18% of screen width
            child: Center(
              child: Semantics(
                selected: isSelected,
                button: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: textStyle,
                    ),
                    if (isCurrentYear == true)
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        margin: EdgeInsets.only(left: screenWidth * 0.01),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.deepOrangeAccent),
              elevation: WidgetStateProperty.all<double>(4),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: () async {
              final values = await showCalendarDatePicker2Dialog(
                context: context,
                config: config,
                dialogSize: Size(screenWidth * 0.8, screenWidth),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                dialogBackgroundColor: Colors.white,
              );
              if (values != null) {
                if (values.length == 1) {
                  ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: values[0]!, end: values[0]!.add(const Duration(hours: 23, minutes: 59, seconds: 59))));
                } else if (values.length == 2)
                  ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: values[0]!, end: values[1]!.add(const Duration(hours: 23, minutes: 59, seconds: 59))));
              }
            },
            child: Text('Select Range'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.white), textAlign: TextAlign.center), // 3% of screen width
          ),
        ],
      ),
    );
  }
}