import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionTypeShowProvider = StateProvider.autoDispose<String>((ref) => "Bitcoin");