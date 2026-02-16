import 'package:flutter/foundation.dart';
import '../../domain/password_generator_service.dart';

/// Provider for password generator functionality
class PasswordGeneratorProvider extends ChangeNotifier {
  final PasswordGeneratorService _service;

  PasswordGeneratorProvider(this._service);

  String _generatedPassword = '';
  PasswordStrength _strength = PasswordStrength.weak;
  PasswordGeneratorConfig _config = const PasswordGeneratorConfig(
    length: 16,
    includeUppercase: true,
    includeLowercase: true,
    includeNumbers: true,
    includeSymbols: true,
  );

  String get generatedPassword => _generatedPassword;
  PasswordStrength get strength => _strength;
  PasswordGeneratorConfig get config => _config;

  /// Generates a new password with the current configuration
  void generatePassword() {
    try {
      _generatedPassword = _service.generate(_config);
      _strength = _service.evaluateStrength(_generatedPassword);
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating password: $e');
    }
  }

  /// Updates the configuration and generates a new password
  void updateConfig(PasswordGeneratorConfig newConfig) {
    _config = newConfig;
    generatePassword();
  }

  /// Updates the password length
  void updateLength(int length) {
    _config = PasswordGeneratorConfig(
      length: length,
      includeUppercase: _config.includeUppercase,
      includeLowercase: _config.includeLowercase,
      includeNumbers: _config.includeNumbers,
      includeSymbols: _config.includeSymbols,
      excludeCharacters: _config.excludeCharacters,
    );
    generatePassword();
  }

  /// Toggles uppercase characters
  void toggleUppercase(bool value) {
    _config = PasswordGeneratorConfig(
      length: _config.length,
      includeUppercase: value,
      includeLowercase: _config.includeLowercase,
      includeNumbers: _config.includeNumbers,
      includeSymbols: _config.includeSymbols,
      excludeCharacters: _config.excludeCharacters,
    );
    generatePassword();
  }

  /// Toggles lowercase characters
  void toggleLowercase(bool value) {
    _config = PasswordGeneratorConfig(
      length: _config.length,
      includeUppercase: _config.includeUppercase,
      includeLowercase: value,
      includeNumbers: _config.includeNumbers,
      includeSymbols: _config.includeSymbols,
      excludeCharacters: _config.excludeCharacters,
    );
    generatePassword();
  }

  /// Toggles numbers
  void toggleNumbers(bool value) {
    _config = PasswordGeneratorConfig(
      length: _config.length,
      includeUppercase: _config.includeUppercase,
      includeLowercase: _config.includeLowercase,
      includeNumbers: value,
      includeSymbols: _config.includeSymbols,
      excludeCharacters: _config.excludeCharacters,
    );
    generatePassword();
  }

  /// Toggles symbols
  void toggleSymbols(bool value) {
    _config = PasswordGeneratorConfig(
      length: _config.length,
      includeUppercase: _config.includeUppercase,
      includeLowercase: _config.includeLowercase,
      includeNumbers: _config.includeNumbers,
      includeSymbols: value,
      excludeCharacters: _config.excludeCharacters,
    );
    generatePassword();
  }

  /// Evaluates the strength of a given password
  PasswordStrength evaluatePasswordStrength(String password) {
    return _service.evaluateStrength(password);
  }
}
