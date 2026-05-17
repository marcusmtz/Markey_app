import 'package:otp/otp.dart';
import '../domain/totp_service.dart';

/// Implementation of TotpService using the otp package
class TotpServiceImpl implements TotpService {
  // TOTP period in seconds (standard is 30 seconds)
  static const int _totpPeriod = 30;

  // Valid Base32 characters
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  @override
  String generateCode(String secret) {
    // Validate the secret first
    if (!validateSecret(secret)) {
      throw ArgumentError('Invalid Base32 secret: $secret');
    }

    // Remove any spaces or dashes that might be in the secret
    final cleanSecret = secret.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    // Get current time in seconds
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate TOTP code using HMAC-SHA1
    final code = OTP.generateTOTPCodeString(
      cleanSecret,
      currentTime,
      length: 6,
      interval: _totpPeriod,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    return code;
  }

  @override
  int getRemainingSeconds() {
    // Get current time in seconds
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Calculate remaining seconds in current period
    final remainingSeconds = _totpPeriod - (currentTime % _totpPeriod);

    return remainingSeconds;
  }

  @override
  bool validateSecret(String secret) {
    if (secret.isEmpty) {
      return false;
    }

    // Remove spaces and dashes for validation
    final cleanSecret = secret.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    // Check if all characters are valid Base32
    for (var i = 0; i < cleanSecret.length; i++) {
      if (!_base32Chars.contains(cleanSecret[i])) {
        return false;
      }
    }

    // Base32 strings should have length that's a multiple of 8 for proper padding
    // However, many TOTP implementations are lenient about this
    // We'll accept any length as long as characters are valid
    return true;
  }

  @override
  String parseSecretFromQR(String qrData) {
    // Expected format: otpauth://totp/[label]?secret=[base32_secret]&issuer=[issuer]
    // Example: otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example

    if (!qrData.startsWith('otpauth://totp/')) {
      throw FormatException(
        'Invalid TOTP QR format: must start with "otpauth://totp/"',
      );
    }

    // Parse the URI
    final uri = Uri.parse(qrData);

    // Extract the secret parameter
    final secret = uri.queryParameters['secret'];

    if (secret == null || secret.isEmpty) {
      throw FormatException(
        'Invalid TOTP QR format: missing "secret" parameter',
      );
    }

    // Validate the extracted secret
    if (!validateSecret(secret)) {
      throw FormatException(
        'Invalid TOTP QR format: secret is not valid Base32',
      );
    }

    return secret.toUpperCase();
  }
}
