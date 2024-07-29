import 'package:Satsails/models/transfer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel extends StateNotifier<User>{
  UserModel(super.state);

  Future<void> setAffiliateCode(String affiliateCode) async {
    final box = await Hive.openBox('user');
    box.put('affiliateCode', affiliateCode);
    state = state.copyWith(affiliateCode: affiliateCode);
  }

  Future<void> setHasAffiliate(bool hasAffiliate) async {
    final box = await Hive.openBox('user');
    box.put('hasAffiliate', hasAffiliate);
    state = state.copyWith(hasAffiliate: hasAffiliate);
  }

  Future<void> setHasCreatedAffiliate(bool hasCreatedAffiliate) async {
    final box = await Hive.openBox('user');
    box.put('hasCreatedAffiliate', hasCreatedAffiliate);
    state = state.copyWith(hasCreatedAffiliate: hasCreatedAffiliate);
  }
}

class User {
  final String affiliateCode;
  final bool hasAffiliate;
  final bool hasCreatedAffiliate;
  User({
    required this.affiliateCode,
    required this.hasAffiliate,
    required this.hasCreatedAffiliate,
  });

  User copyWith({
    String? affiliateCode,
    bool? hasAffiliate,
    bool? hasCreatedAffiliate,
  }) {
    return User(
      affiliateCode: affiliateCode ?? this.affiliateCode,
      hasAffiliate: hasAffiliate ?? this.hasAffiliate,
      hasCreatedAffiliate: hasCreatedAffiliate ?? this.hasCreatedAffiliate,
    );
  }
}

class UserService {
  Future<String> createUserRequest(String liquidAddress) async {
    final response = await http.post(
      Uri.parse('https://splitter.satsails.com/users'),
      body: jsonEncode({
        'user': {
          'liquid_address': liquidAddress,
        }
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['payment_id'];
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<bool> addAffiliateCode(String paymentId, String affiliateCode) async {
    final response = await http.post(
      Uri.parse('https://splitter.satsails.com/add_affiliate'),
      body: jsonEncode({
        'user': {
          'payment_id': paymentId,
          'affiliate_code': affiliateCode,
        }
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonDecode(response.body)['error'];
    }
  }

  Future<bool> createAffiliateCode(String paymentId, String affiliateCode, String liquidAddress) async {
    final response = await http.post(
      Uri.parse('https://splitter.satsails.com/affiliates'),
      body: jsonEncode({
        'affiliate': {
          'affiliate_owner': paymentId,
          'code': affiliateCode,
          'liquid_address': liquidAddress,
        }
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw (jsonDecode(response.body)['code']);
    }
  }

  Future<List<Transfer>> getUserTransactions(String pixPaymentCode) async {
    final uri = Uri.parse('https://splitter.satsails.com/user_transfers')
        .replace(queryParameters: {
      'payment_id': pixPaymentCode,
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<Transfer> transfers = jsonResponse.map((item) => Transfer.fromJson(item as Map<String, dynamic>)).toList();
      return transfers;
    } else {
      throw Exception('Failed to get user transactions: ${response.body}');
    }
  }

  Future<String> getAmountTransferred(String pixPaymentCode) async {
    final uri = Uri.parse('https://splitter.satsails.com/amount_transfered_by_day')
        .replace(queryParameters: {
      'payment_id': pixPaymentCode,
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get amount transferred');
    }
  }

  Future<int> affiliateNumberOfUsers(String affiliateCode) async {
    final uri = Uri.parse('https://splitter.satsails.com/number_of_users')
        .replace(queryParameters: {
         'code': affiliateCode,
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get number of users');
    }
  }

  Future<String> affiliateEarnings(String affiliateCode) async {
    final uri = Uri.parse('https://splitter.satsails.com/value_purchased_by_affiliate')
        .replace(queryParameters: {
      'code': affiliateCode,
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get amount generated by affiliate');
    }
  }
}