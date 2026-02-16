/// Abstract interface for password generation operations
abstract class PasswordGeneratorService {
  /// Generates a password based on the provided configuration
  /// Returns the generated password string
  String generate(PasswordGeneratorConfig config);

  /// Evaluates the strength of a given password
  /// Returns a PasswordStrength enum value
  PasswordStrength evaluateStrength(String password);
}

/// Configuration for password generation
class PasswordGeneratorConfig {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final String? excludeCharacters;

  const PasswordGeneratorConfig({
    required this.length,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
    this.excludeCharacters,
  });

  /// Validates the configuration
  /// Throws ArgumentError if configuration is invalid
  void validate() {
    if (length < 8 || length > 64) {
      throw ArgumentError(
        'Password length must be between 8 and 64 characters',
      );
    }

    if (!includeUppercase &&
        !includeLowercase &&
        !includeNumbers &&
        !includeSymbols) {
      throw ArgumentError('At least one character type must be selected');
    }
  }

  /// Returns true if the configuration is valid
  bool get isValid {
    try {
      validate();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Enum representing password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong;

  /// Returns a human-readable description of the strength
  String get description {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  /// Returns a score from 0-100 representing the strength
  int get score {
    switch (this) {
      case PasswordStrength.weak:
        return 25;
      case PasswordStrength.medium:
        return 50;
      case PasswordStrength.strong:
        return 75;
      case PasswordStrength.veryStrong:
        return 100;
    }
  }
}
