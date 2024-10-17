import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/validations/address_validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AffiliateModel extends StateNotifier<Affiliate> {
  AffiliateModel(super.state);

  Future<void> setInsertedAffiliateCode(String insertedAffiliateCode) async {
    final upperCaseCode = insertedAffiliateCode.toUpperCase();
    final box = await Hive.openBox('affiliate');
    box.put('insertedAffiliateCode', upperCaseCode);
    state = state.copyWith(insertedAffiliateCode: upperCaseCode);
  }

  Future<void> setCreatedAffiliateCode(String createdAffiliateCode) async {
    final upperCaseCode = createdAffiliateCode.toUpperCase();
    final box = await Hive.openBox('affiliate');
    box.put('createdAffiliateCode', upperCaseCode);
    state = state.copyWith(createdAffiliateCode: upperCaseCode);
  }

  Future<void> setLiquidAddress(String createdAffiliateLiquidAddress) async {
    final box = await Hive.openBox('affiliate');
    box.put('liquidAddress', createdAffiliateLiquidAddress);
    state = state.copyWith(createdAffiliateLiquidAddress: createdAffiliateLiquidAddress);
  }
}

class Affiliate {
  final String insertedAffiliateCode;
  final String createdAffiliateCode;
  final String createdAffiliateLiquidAddress;

  Affiliate({
    required this.insertedAffiliateCode,
    required this.createdAffiliateCode,
    required this.createdAffiliateLiquidAddress,
  });

  Affiliate copyWith({
    String? insertedAffiliateCode,
    String? createdAffiliateCode,
    String? createdAffiliateLiquidAddress,
  }) {
    return Affiliate(
      insertedAffiliateCode: insertedAffiliateCode ?? this.insertedAffiliateCode,
      createdAffiliateCode: createdAffiliateCode ?? this.createdAffiliateCode,
      createdAffiliateLiquidAddress: createdAffiliateLiquidAddress ?? this.createdAffiliateLiquidAddress,
    );
  }

  factory Affiliate.fromJson(Map<String, dynamic> json) {
    return Affiliate(
      insertedAffiliateCode: json['inserted_affiliate_code'],
      createdAffiliateCode: json['created_affiliate_code'],
      createdAffiliateLiquidAddress: json['liquid_address'],
    );
  }
}



class AffiliateService {
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

  static Future<Result<String>> createAffiliateCode(String liquidAddress, String auth) async {
    bool isValid = await isValidLiquidAddress(liquidAddress);
    if (isValid) {
      try {
        final response = await http.post(
          Uri.parse(dotenv.env['BACKEND']! + '/affiliates'),
          body: jsonEncode({
            'affiliate': {
              'liquid_address': liquidAddress,
            }
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': auth,
          },
        );

        if (response.statusCode == 201) {
          return Result(data: jsonDecode(response.body)['code']);
        } else {
          final errorMsg = jsonDecode(response.body)['code'].first ?? 'Failed to create affiliate code';
          return Result(error: errorMsg);
        }
      } catch (e) {
        return Result(error: 'An error has occurred. Please check your internet connection or contact support');
      }
    } else {
      return Result(error: 'Invalid liquid address');
    }
  }

  static Future<Result<int>> affiliateNumberOfUsers(String affiliateCode, String auth) async {
    try {
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/affiliates/number_of_users')
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
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<String>> affiliateEarnings(String affiliateCode, String auth) async {
    try {
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/affiliates/value_earned_by_affiliate')
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
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<String>> affiliateUsersSpend(String affiliateCode, String auth) async {
    try {
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/affiliates/total_value_purchased_by_clients')
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
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }
  static Future<Result<List<ParsedTransfer>>> getAllTransfersFromAffiliateUsers(String affiliateCode, String auth) async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['BACKEND']! + '/affiliates/all_transfers')
            .replace(queryParameters: {
          'code': affiliateCode,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> transfers = jsonDecode(response.body);
        return Result(data: transfers.map((transfer) => ParsedTransfer.fromJson(transfer)).toList());
      } else {
        return Result(error: 'Failed to get all transfers');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }
}