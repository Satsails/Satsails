import 'dart:collection';
import 'dart:math';
import 'package:Satsails/models/breez/lnurl_webhook_manager.dart';

class UsernameFormatter {
  static const int _maxCacheSize = 100;
  static final LinkedHashMap<String, String> _sanitizeCache = LinkedHashMap<String, String>();

  static String sanitize(String rawUsername) {
    if (rawUsername.isEmpty) return '';
    if (_sanitizeCache.containsKey(rawUsername)) {
      final String value = _sanitizeCache.remove(rawUsername)!;
      _sanitizeCache[rawUsername] = value;
      return value;
    }

    String sanitized = rawUsername.trim();
    sanitized = _removeLeadingTrailingDots(sanitized);
    sanitized = sanitized.toLowerCase().replaceAll(' ', '');

    _addToCache(rawUsername, sanitized);
    return sanitized;
  }

  static void _addToCache(String key, String value) {
    if (_sanitizeCache.length >= _maxCacheSize) {
      _sanitizeCache.remove(_sanitizeCache.keys.first);
    }
    _sanitizeCache[key] = value;
  }

  static String _removeLeadingTrailingDots(String input) {
    if (input.isEmpty) return input;
    String result = input;
    while (result.isNotEmpty && result.startsWith('.')) {
      result = result.substring(1);
    }
    while (result.isNotEmpty && result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  static String formatDefaultProfileName(String? defaultProfileName) {
    return sanitize(defaultProfileName ?? '');
  }
}


class UsernameGenerator {
  static const int _discriminatorLength = 4;
  static const int _maxDiscriminatorValue = 10000;
  static final Random _secureRandom = Random.secure();

  static String generateUsername(String baseUsername, int attempt) {
    if (baseUsername.isEmpty || attempt < 0) {
      throw ArgumentError('Invalid parameters for username generation.');
    }
    if (attempt == 0) return baseUsername;

    final String discriminatorStr = _secureRandom.nextInt(_maxDiscriminatorValue).toString();
    final String formattedDiscriminator = discriminatorStr.padLeft(_discriminatorLength, '0');
    return '$baseUsername$formattedDiscriminator';
  }
}


class UsernameResolver {
  final BreezPreferences breezPreferences;

  UsernameResolver(this.breezPreferences);

  Future<String> resolveUsername({
    String? recoveredLightningAddress,
    String? baseUsername,
  }) async {
    // Priority 1: From recovered address
    if (recoveredLightningAddress?.isNotEmpty ?? false) {
      return recoveredLightningAddress!.split('@').first;
    }
    // Priority 2: From explicit parameter
    if (baseUsername?.isNotEmpty ?? false) {
      return baseUsername!;
    }
    // Priority 3: From stored preferences
    final storedUsername = await breezPreferences.getLnAddressUsername();
    if (storedUsername?.isNotEmpty ?? false) {
      return storedUsername!;
    }
    // Priority 4 (NEW): Generate a random username as a fallback
    return RandomUsernameGenerator.generate();
  }
}

class RandomUsernameGenerator {
  static final _random = Random.secure();

  static const _adjectives = [
    'agile', 'azure', 'bold', 'brave', 'bright', 'brisk', 'calm', 'chief',
    'clear', 'clever', 'cobalt', 'cool', 'dapper', 'deft', 'eager', 'epic',
    'fabled', 'fast', 'fierce', 'fine', 'firm', 'fresh', 'gentle', 'golden',
    'grand', 'great', 'happy', 'honest', 'humble', 'jolly', 'keen', 'kind',
    'lively', 'loyal', 'lucid', 'major', 'merry', 'neat', 'noble', 'placid',
    'prime', 'proud', 'quick', 'quiet', 'regal', 'sage', 'sharp', 'sleek',
    'sound', 'swift'
  ]; // 50 adjectives

  static const _nouns = [
    'admiral', 'anchor', 'beacon', 'boat', 'captain', 'clipper', 'coast', 'compass',
    'coral', 'cove', 'crew', 'current', 'dawn', 'deck', 'dock', 'expedition',
    'fleet', 'fluke', 'galleon', 'gulf', 'harbor', 'haven', 'horizon', 'island',
    'jetty', 'journey', 'knot', 'lagoon', 'launch', 'marina', 'mariner', 'mast',
    'navigator', 'ocean', 'pier', 'pilot', 'port', 'quest', 'raft', 'reef',
    'rudder', 'sailor', 'schooner', 'sea', 'ship', 'shore', 'tide', 'voyage',
    'whale', 'yacht'
  ]; // 50 nouns

  static String generate() {
    final adj = _adjectives[_random.nextInt(_adjectives.length)];
    final noun = _nouns[_random.nextInt(_nouns.length)];
    final number = _random.nextInt(9000) + 1000;
    return '$adj$noun$number';
  }
}
