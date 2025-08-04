import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class Lnurl {
  final String pubkey;
  final String? username;
  final String? webhookUrl;
  final String? offer;
  final DateTime registeredAt;
  final String? lightningAddress;

  Lnurl({
    required this.pubkey,
    this.username,
    this.webhookUrl,
    this.offer,
    required this.registeredAt,
    this.lightningAddress,
  });

  factory Lnurl.fromJson(Map<String, dynamic> json) {
    final data = json['registration'] ?? json;
    return Lnurl(
      pubkey: data['pubkey'] ?? '',
      username: data['username'],
      webhookUrl: data['webhook_url'],
      offer: data['offer'],
      registeredAt:
      DateTime.tryParse(data['registered_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      lightningAddress: data['lightning_address'],
    );
  }
}

const _lnAddressStorageKey = 'lnurl';
const _storageBoxName = 'lightningBox';


class LnAddressNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storageBox = await Hive.openBox(_storageBoxName);
    return storageBox.get(_lnAddressStorageKey);
  }

  Future<void> updateLnAddress(String? address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storageBox = await Hive.openBox(_storageBoxName);

      if (address == null || address.isEmpty) {
        await storageBox.delete(_lnAddressStorageKey);
        return null;
      } else {
        await storageBox.put(_lnAddressStorageKey, address);
        return address;
      }
    });
  }
}


class UsernameConflictException implements Exception {
  final String message;
  UsernameConflictException(this.message);

  @override
  String toString() => 'UsernameConflictException: $message';
}

enum RegistrationType {
  update,
  newRegistration,
  recovery,
  ownershipTransfer
}