import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/validations/address_validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

const FlutterSecureStorage _storage = FlutterSecureStorage();

class UserModel extends StateNotifier<User> {
  UserModel(super.state);

  Future<void> setAffiliateCode(String affiliateCode) async {
    final box = await Hive.openBox('user');
    box.put('affiliateCode', affiliateCode);
    state = state.copyWith(affiliateCode: affiliateCode);
  }

  Future<void> sethasInsertedAffiliate(bool hasInsertedAffiliate) async {
    final box = await Hive.openBox('user');
    box.put('hasInsertedAffiliate', hasInsertedAffiliate);
    state = state.copyWith(hasInsertedAffiliate: hasInsertedAffiliate);
  }

  Future<void> setHasCreatedAffiliate(bool hasCreatedAffiliate) async {
    final box = await Hive.openBox('user');
    box.put('hasCreatedAffiliate', hasCreatedAffiliate);
    state = state.copyWith(hasCreatedAffiliate: hasCreatedAffiliate);
  }

  Future<void> setPaymentId(String paymentCode) async {
    final box = await Hive.openBox('user');
    box.put('paymentId', paymentCode);
    state = state.copyWith(paymentId: paymentCode);
  }

  Future<void> serOnboarded(bool onboardingStatus) async {
    final box = await Hive.openBox('user');
    box.put('onboarding', onboardingStatus);
    state = state.copyWith(onboarded: onboardingStatus);
  }

  Future<void> setRecoveryCode(String recoveryCode) async {
    await _storage.write(key: 'recoveryCode', value: recoveryCode);
    state = state.copyWith(recoveryCode: recoveryCode);
  }
}

class User {
  final String? affiliateCode;
  final bool hasInsertedAffiliate;
  final bool hasCreatedAffiliate;
  final String recoveryCode;
  final String paymentId;
  final bool? onboarded;

  User({
    this.affiliateCode,
    this.hasInsertedAffiliate = false,
    this.hasCreatedAffiliate = false,
    required this.recoveryCode,
    required this.paymentId,
    this.onboarded,
  });

  User copyWith({
    String? affiliateCode,
    bool? hasInsertedAffiliate,
    bool? hasCreatedAffiliate,
    String? recoveryCode,
    String? paymentId,
    bool? onboarded,
  }) {
    return User(
      affiliateCode: affiliateCode ?? this.affiliateCode,
      hasInsertedAffiliate: hasInsertedAffiliate ?? this.hasInsertedAffiliate,
      hasCreatedAffiliate: hasCreatedAffiliate ?? this.hasCreatedAffiliate,
      recoveryCode: recoveryCode ?? this.recoveryCode,
      paymentId: paymentId ?? this.paymentId,
      onboarded: onboarded ?? this.onboarded,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      recoveryCode: json['user']['authentication_token'],
      paymentId: json['user']['payment_id'],
      hasInsertedAffiliate: json['hasInsertedAffiliate'] ?? false,
      hasCreatedAffiliate: json['hasCreatedAffiliate'] ?? false,
    );
  }
}

class UserService {
  static Future<Result<User>> createUserRequest(String liquidAddress) async {
    try {
      final response = await http.post(
        Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/users'),
        body: jsonEncode({
          'user': {
            'liquid_address': liquidAddress,
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
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<bool>> addAffiliateCode(String paymentId, String affiliateCode, String auth) async {
    try {
      final response = await http.post(
        Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/add_affiliate'),
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
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<bool>> createAffiliateCode(String paymentId, String affiliateCode, String liquidAddress, String auth) async {
    bool isValid = await isValidLiquidAddress(liquidAddress);
    if (isValid) {
      try {
        final response = await http.post(
          Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/affiliates'),
          body: jsonEncode({
            'affiliate': {
              'affiliate_owner': paymentId,
              'code': affiliateCode,
              'liquid_address': liquidAddress,
            }
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': auth,
          },
        );

        if (response.statusCode == 201) {
          return Result(data: true);
        } else {
          String errorMsg = jsonDecode(response.body)['code'] ?? 'Failed to create affiliate code';
          return Result(error: errorMsg);
        }
      } catch (e) {
        return Result(error: 'An error occurred: $e');
      }
    } else {
      return Result(error: 'Invalid liquid address');
    }
  }

  static Future<Result<List<Transfer>>> getUserTransactions(String pixPaymentCode, String auth) async {
    try {
      final uri = Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/user_transfers')
          .replace(queryParameters: {
        'payment_id': pixPaymentCode,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Transfer> transfers = jsonResponse.map((item) => Transfer.fromJson(item as Map<String, dynamic>)).toList();
        return Result(data: transfers);
      } else {
        return Result(error: 'Failed to get user transactions: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<String>> getAmountTransferred(String pixPaymentCode, String auth) async {
    try {
      final uri = Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/amount_transfered_by_day')
          .replace(queryParameters: {
        'payment_id': pixPaymentCode,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get amount transferred');
      }
    } catch (e) {
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<int>> affiliateNumberOfUsers(String affiliateCode, String auth) async {
    try {
      final uri = Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/number_of_users')
          .replace(queryParameters: {
        'code': affiliateCode,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get number of users');
      }
    } catch (e) {
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<String>> affiliateEarnings(String affiliateCode, String auth) async {
    try {
      final uri = Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/value_purchased_by_affiliate')
          .replace(queryParameters: {
        'code': affiliateCode,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get amount generated by affiliate');
      }
    } catch (e) {
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<String>> updateLiquidAddress(String liquidAddress, String auth) async {
    try {
      final response = await http.patch(
        Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/update_liquid_address'),
        body: jsonEncode({
          'user': {
            'liquid_address': liquidAddress,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: 'OK');
      } else {
        return Result(error: 'Failed to update liquid address');
      }
    } catch (e) {
      return Result(error: 'An error occurred: $e');
    }
  }

  static Future<Result<User>> showUser(String auth) async {
    try {
      final response = await http.get(
        Uri.parse('https://897b-2001-8a0-e374-d300-f12f-78c-d09b-4bf4.ngrok-free.app/show_user'),
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
      return Result(error: 'An error occurred: $e');
    }
  }
}
