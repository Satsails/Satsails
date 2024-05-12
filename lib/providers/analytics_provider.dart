import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';


final dateTimeSelectProvider = StateNotifierProvider.autoDispose<DateTimeSelectProvider, DateTimeSelect>((ref) {
  return DateTimeSelectProvider(DateTimeSelect(start: DateTime.utc(0), end: DateTime.now()));
});
