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
      registeredAt: DateTime.tryParse(data['registered_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      lightningAddress: data['lightning_address'],
    );
  }
}

// lnurl_pay_request.dart

/// A request to register a new LNURL-pay webhook.
class RegisterLnurlPayRequest {
  final int time;
  final String webhookUrl;
  final String signature;
  final String? username;
  final String? offer;

  RegisterLnurlPayRequest({
    required this.time,
    required this.webhookUrl,
    required this.signature,
    this.username,
    this.offer,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'webhook_url': webhookUrl,
    'signature': signature,
    if (username != null) 'username': username,
    if (offer != null) 'offer': offer,
  };
}

/// A request to unregister or recover an LNURL-pay webhook.
class UnregisterRecoverLnurlPayRequest {
  final int time;
  final String webhookUrl;
  final String signature;

  UnregisterRecoverLnurlPayRequest({
    required this.time,
    required this.webhookUrl,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'webhook_url': webhookUrl,
    'signature': signature,
  };
}


// signed_request_data.dart

/// A container for the timestamp and signature of a signed request.
class SignedRequestData {
  final int timestamp;
  final String signature;

  SignedRequestData({required this.timestamp, required this.signature});
}


// lnurl_exceptions.dart

/// Thrown when a requested username is already taken.
class UsernameConflictException implements Exception {
  final String message;
  UsernameConflictException(this.message);

  @override
  String toString() => 'UsernameConflictException: $message';
}

/// Thrown when a webhook is not found during a recovery attempt.
class WebhookNotFoundException implements Exception {
  final String message;
  WebhookNotFoundException(this.message);

  @override
  String toString() => 'WebhookNotFoundException: $message';
}

/// Thrown when an operation fails after the maximum number of retries.
class MaxRetriesExceededException implements Exception {
  @override
  String toString() => 'MaxRetriesExceededException: The operation failed after the maximum number of retries.';
}

/// A generic exception for webhook registration failures.
class RegisterWebhookException implements Exception {
  final String message;
  RegisterWebhookException(this.message);
  @override
  String toString() => 'RegisterWebhookException: $message';
}

/// A generic exception for webhook URL generation failures.
class GenerateWebhookUrlException implements Exception {
  final String message;
  GenerateWebhookUrlException(this.message);
  @override
  String toString() => 'GenerateWebhookUrlException: $message';
}

class RegistrationType {
  static const String newRegistration = 'newRegistration';
  static const String update = 'update';
  static const String recovery = 'recovery';
  static const String ownershipTransfer = 'ownershipTransfer';
}
