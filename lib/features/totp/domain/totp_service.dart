/// Abstract interface for TOTP (Time-based One-Time Password) operations
abstract class TotpService {
  /// Generates a 6-digit TOTP code from the given Base32 secret
  /// Returns the current TOTP code as a string
  /// Throws ArgumentError if the secret is invalid
  String generateCode(String secret);

  /// Returns the number of seconds remaining until the current TOTP code expires
  /// TOTP codes are valid for 30 seconds
  int getRemainingSeconds();

  /// Validates if the given secret is a valid Base32 string
  /// Returns true if valid, false otherwise
  bool validateSecret(String secret);

  /// Parses a TOTP secret from a QR code data string
  /// Expects format: otpauth://totp/[label]?secret=[base32_secret]&issuer=[issuer]
  /// Returns the Base32 secret if parsing is successful
  /// Throws FormatException if the QR data format is invalid
  String parseSecretFromQR(String qrData);
}
