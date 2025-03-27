import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = StateProvider<int>((ref) => 0);

final shouldUpdateMemoryProvider = StateProvider<bool>((ref) => true);