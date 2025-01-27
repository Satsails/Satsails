import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/auth_model.dart';

final authModelProvider = Provider<AuthModel>((ref) {
  return AuthModel();
});
