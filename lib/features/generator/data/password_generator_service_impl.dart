import 'dart:math';
import '../domain/password_generator_service.dart';

/// Implementation of PasswordGeneratorService using cryptographically secure random
class PasswordGeneratorServiceImpl implements PasswordGeneratorService {
  // Character sets for password generation
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  final Random _secureRandom = Random.secure();

  @override
  String generate(PasswordGeneratorConfig config) {
    // Validate configuration
    config.validate();

    // Build character pool based on configuration
    final charPool = _buildCharacterPool(config);

    if (charPool.isEmpty) {
      throw ArgumentError('Character pool is empty after applying exclusions');
    }

    // Generate password ensuring at least one character from each selected type
    return _generateWithGuaranteedTypes(config, charPool);
  }

  @override
  PasswordStrength evaluateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    // Calculate entropy
    final entropy = _calculateEntropy(password);

    // Evaluate based on entropy thresholds
    // Entropy thresholds:
    // < 40 bits: weak
    // 40-60 bits: medium
    // 60-80 bits: strong
    // >= 80 bits: very strong
    if (entropy < 40) {
      return PasswordStrength.weak;
    } else if (entropy < 60) {
      return PasswordStrength.medium;
    } else if (entropy < 80) {
      return PasswordStrength.strong;
    } else {
      return PasswordStrength.veryStrong;
    }
  }

  /// Builds the character pool based on configuration
  String _buildCharacterPool(PasswordGeneratorConfig config) {
    final buffer = StringBuffer();

    if (config.includeUppercase) {
      buffer.write(_uppercase);
    }
    if (config.includeLowercase) {
      buffer.write(_lowercase);
    }
    if (config.includeNumbers) {
      buffer.write(_numbers);
    }
    if (config.includeSymbols) {
      buffer.write(_symbols);
    }

    var pool = buffer.toString();

    // Remove excluded characters if specified
    if (config.excludeCharacters != null &&
        config.excludeCharacters!.isNotEmpty) {
      for (var char in config.excludeCharacters!.split('')) {
        pool = pool.replaceAll(char, '');
      }
    }

    return pool;
  }

  /// Generates password ensuring at least one character from each selected type
  String _generateWithGuaranteedTypes(
    PasswordGeneratorConfig config,
    String charPool,
  ) {
    final password = <String>[];
    final requiredChars = <String>[];

    // Add at least one character from each selected type
    if (config.includeUppercase) {
      final filtered = _filterExcluded(_uppercase, config.excludeCharacters);
      if (filtered.isNotEmpty) {
        requiredChars.add(_getRandomChar(filtered));
      }
    }
    if (config.includeLowercase) {
      final filtered = _filterExcluded(_lowercase, config.excludeCharacters);
      if (filtered.isNotEmpty) {
        requiredChars.add(_getRandomChar(filtered));
      }
    }
    if (config.includeNumbers) {
      final filtered = _filterExcluded(_numbers, config.excludeCharacters);
      if (filtered.isNotEmpty) {
        requiredChars.add(_getRandomChar(filtered));
      }
    }
    if (config.includeSymbols) {
      final filtered = _filterExcluded(_symbols, config.excludeCharacters);
      if (filtered.isNotEmpty) {
        requiredChars.add(_getRandomChar(filtered));
      }
    }

    // Add required characters first
    password.addAll(requiredChars);

    // Fill remaining length with random characters from pool
    final remainingLength = config.length - requiredChars.length;
    for (var i = 0; i < remainingLength; i++) {
      password.add(_getRandomChar(charPool));
    }

    // Shuffle the password to randomize position of required characters
    _shuffleList(password);

    return password.join();
  }

  /// Filters out excluded characters from a character set
  String _filterExcluded(String charSet, String? excludeCharacters) {
    if (excludeCharacters == null || excludeCharacters.isEmpty) {
      return charSet;
    }

    var filtered = charSet;
    for (var char in excludeCharacters.split('')) {
      filtered = filtered.replaceAll(char, '');
    }
    return filtered;
  }

  /// Gets a random character from the given string
  String _getRandomChar(String chars) {
    final index = _secureRandom.nextInt(chars.length);
    return chars[index];
  }

  /// Shuffles a list in place using Fisher-Yates algorithm
  void _shuffleList(List<String> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = _secureRandom.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Calculates the entropy of a password in bits
  double _calculateEntropy(String password) {
    if (password.isEmpty) {
      return 0.0;
    }

    // Determine character pool size based on what's actually in the password
    var poolSize = 0;

    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSymbols = password.contains(RegExp(r'[^a-zA-Z0-9]'));

    if (hasLowercase) poolSize += 26;
    if (hasUppercase) poolSize += 26;
    if (hasNumbers) poolSize += 10;
    if (hasSymbols) poolSize += 32; // Approximate symbol count

    if (poolSize == 0) {
      return 0.0;
    }

    // Entropy = log2(poolSize^length) = length * log2(poolSize)
    final entropy = password.length * (log(poolSize) / ln2);

    return entropy;
  }
}
