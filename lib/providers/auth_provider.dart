import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/auth_model.dart';

final authModelProvider = StateProvider<AuthModel>((ref) {
  return AuthModel();
});

