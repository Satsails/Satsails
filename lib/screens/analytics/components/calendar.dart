import 'package:Satsails/translations/translations.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

final today = DateUtils.dateOnly(DateTime.now());

// Define the selectedButtonProvider to manage the selected segment
final selectedButtonProvider = StateProvider.autoDispose<int>((ref) => 1);

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  @override
  Widget build(BuildContext context) {
    return _buildCalendarDialogButton(context, ref);
  }

  Widget _buildCalendarDialogButton(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    const dayTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
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
      padding: EdgeInsets.all(screenWidth * 0.01),
      child: Column(
        children: [
          FractionallySizedBox(
            widthFactor: 0.9,
            child: SegmentedButtonSlide(
              entries: [
                SegmentedButtonSlideEntry(
                  label: "1w".i18n(ref),
                ),
                SegmentedButtonSlideEntry(
                  label: "1m",
                ),
                SegmentedButtonSlideEntry(
                  label: "6m",
                ),
                SegmentedButtonSlideEntry(
                  label: "Custom".i18n(ref),
                ),
              ],
              selectedEntry: ref.watch(selectedButtonProvider),
              onChange: (selected) async {
                final DateTime now = DateTime.now();
                DateTime startDate;

                switch (selected) {
                  case 0:
                    startDate = now.subtract(Duration(days: now.weekday - 1));
                    ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: startDate, end: now));
                    break;
                  case 1:
                    startDate = DateTime(now.year, now.month - 1, now.day);
                    ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: startDate, end: now));
                    break;
                  case 2:
                    startDate = DateTime(now.year, now.month - 6, now.day);
                    ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: startDate, end: now));
                    break;
                  case 3:
                  default:
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
                      } else if (values.length == 2) {
                        ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(start: values[0]!, end: values[1]!.add(const Duration(hours: 23, minutes: 59, seconds: 59))));
                      }
                    }
                    break;
                }
                ref.read(selectedButtonProvider.notifier).state = selected;
              },
              colors: SegmentedButtonSlideColors(
                barColor: Colors.grey.withOpacity(0.08),
                backgroundSelectedColor: Colors.orangeAccent,
                foregroundSelectedColor: Colors.white,
                foregroundUnselectedColor: Colors.black,
                hoverColor: Colors.orangeAccent.withOpacity(0.2),
              ),
              slideShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
              margin: EdgeInsets.only(
                top: screenWidth * 0.02,
                bottom: screenWidth * 0.02,
              ),
              height: screenWidth * 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
