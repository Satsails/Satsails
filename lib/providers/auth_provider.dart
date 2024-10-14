import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/auth_model.dart';

final authModelProvider = Provider.autoDispose<AuthModel>((ref) {
  SecureKeyManager.generateAndStoreKey();
  return AuthModel();
});
