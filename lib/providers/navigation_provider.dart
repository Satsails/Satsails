import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = StateProvider.autoDispose<int>((ref) => 0);