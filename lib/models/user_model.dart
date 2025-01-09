// this screen needs some heavy refactoring. On version "Unyielding conviction" we shall totally redo this spaghetti code.
import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/purchase_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_beams/pusher_beams.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class UserModel extends StateNotifier<User> {
  UserModel(super.state);
  Future<void> setPaymentId(String paymentCode) async {
    final box = await Hive.openBox('user');
    box.put('paymentId', paymentCode);
    state = state.copyWith(paymentId: paymentCode);
  }

  Future<void> setAffiliateCode(String affiliateCode) async {
    final box = await Hive.openBox('user');
    box.put('affiliateCode', affiliateCode);
    state = state.copyWith(affiliateCode: affiliateCode);
  }

  Future<void> setRecoveryCode(String recoveryCode) async {
    await _storage.write(key: 'recoveryCode', value: recoveryCode);
    state = state.copyWith(recoveryCode: recoveryCode);
  }

  Future<void> setHasUploadedAffiliateCode(bool hasUploadedAffiliateCode) async {
    final box = await Hive.openBox('user');
    box.put('hasUploadedAffiliateCode', hasUploadedAffiliateCode);
    state = state.copyWith(hasUploadedAffiliateCode: hasUploadedAffiliateCode);
  }
}

class User {
  final String recoveryCode;
  final String paymentId;
  final String? affiliateCode;
  final bool hasUploadedAffiliateCode;

  User({
    required this.recoveryCode,
    required this.paymentId,
    required this.affiliateCode,
    required this.hasUploadedAffiliateCode,
  });

  User copyWith({
    String? recoveryCode,
    String? paymentId,
    String? affiliateCode,
    bool? hasUploadedAffiliateCode,
  }) {
    return User(
      recoveryCode: recoveryCode ?? this.recoveryCode,
      paymentId: paymentId ?? this.paymentId,
      affiliateCode: affiliateCode ?? this.affiliateCode,
      hasUploadedAffiliateCode: hasUploadedAffiliateCode ?? this.hasUploadedAffiliateCode,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      recoveryCode: json['user']['authentication_token'],
      paymentId: json['user']['payment_id'],
      affiliateCode: json['inserted_affiliate']['code'] ?? '',
      hasUploadedAffiliateCode: false,
    );
  }
}

class UserService {
  static Future<Result<User>> createUserRequest(String auth, String liquidAddress, int liquidIndex) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/users'),
        body: jsonEncode({
          'user': {
            'authentication_token': auth,
            'liquid_address': liquidAddress,
            'liquid_address_index': liquidIndex,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return Result(data: User.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'Failed to create user: ${response.body}');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<User>> showUser(String auth) async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['BACKEND']! + '/users/show_user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: User.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'Failed to show user');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static BeamsAuthProvider getPusherAuth(String auth, String userId) {
    try {
      final BeamsAuthProvider response = BeamsAuthProvider()
        ..authUrl = dotenv.env['BACKEND']! + '/users/get_pusher_auth'
        ..headers = {
          'Content-Type': 'application/json',
          'Authorization': auth,
        }
        ..queryParams = {
          'user_id': userId
        }
        ..credentials = 'omit';

      return response;
    } catch (e) {
      throw Exception(
          'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<bool>> addAffiliateCode(String paymentId, String affiliateCode, String auth) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/users/add_affiliate'),
        body: jsonEncode({
          'user': {
            'payment_id': paymentId,
            'affiliate_code': affiliateCode,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: true);
      } else {
        String errorMsg = jsonDecode(response.body)['error'] ?? 'Failed to add affiliate code';
        return Result(error: errorMsg);
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }
}