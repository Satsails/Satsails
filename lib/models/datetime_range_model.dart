import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateTimeSelectProvider extends StateNotifier<DateTimeSelect> {
  DateTimeSelectProvider(super.DateTimeSelect);

  void update(DateTimeSelect DateTimeSelect) {
    state = DateTimeSelect;
  }
}

class DateTimeSelect {
  DateTimeSelect({required DateTime start, required DateTime end})
      : _start = start,
        _end = end;

  final DateTime _start;
  final DateTime _end;

  int get start => _start.millisecondsSinceEpoch ~/ 1000;
  int get end => _end.millisecondsSinceEpoch ~/ 1000;

  DateTimeSelect copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return DateTimeSelect(
      start: start ?? _start,
      end: end ?? _end,
    );
  }
}