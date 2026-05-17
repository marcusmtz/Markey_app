import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/features/totp/data/totp_service_impl.dart';
import 'package:markey_app/features/totp/domain/totp_service.dart';

void main() {
  late TotpService totpService;

  setUp(() {
    totpService = TotpServiceImpl();
  });

  group('TotpService - generateCode', () {
    test('generates 6-digit code with valid Base32 secret', () {
      // Known test secret
      const secret = 'JBSWY3DPEHPK3PXP';

      final code = totpService.generateCode(secret);

      // Verify code is 6 digits
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
      expect(int.parse(code), greaterThanOrEqualTo(0));
      expect(int.parse(code), lessThanOrEqualTo(999999));
    });

    test('generates code with secret containing spaces and dashes', () {
      // Secret with spaces and dashes (should be cleaned)
      const secret = 'JBSW Y3DP-EHPK 3PXP';

      final code = totpService.generateCode(secret);

      // Should still generate valid 6-digit code
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('throws ArgumentError for invalid Base32 secret', () {
      // Invalid characters (0, 1, 8, 9 are not in Base32)
      const invalidSecret = 'INVALID01289';

      expect(
        () => totpService.generateCode(invalidSecret),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for empty secret', () {
      expect(() => totpService.generateCode(''), throwsArgumentError);
    });
  });

  group('TotpService - getRemainingSeconds', () {
    test('returns value between 1 and 30', () {
      final remaining = totpService.getRemainingSeconds();

      expect(remaining, greaterThanOrEqualTo(1));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('returns different values when called at different times', () async {
      final first = totpService.getRemainingSeconds();

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      final second = totpService.getRemainingSeconds();

      // Should be same or decreased (unless we crossed a 30-second boundary)
      expect(second, lessThanOrEqualTo(first));
    });
  });

  group('TotpService - validateSecret', () {
    test('validates correct Base32 secret', () {
      const validSecret = 'JBSWY3DPEHPK3PXP';

      expect(totpService.validateSecret(validSecret), isTrue);
    });

    test('validates Base32 secret with spaces and dashes', () {
      const secretWithSpaces = 'JBSW Y3DP-EHPK 3PXP';

      expect(totpService.validateSecret(secretWithSpaces), isTrue);
    });

    test('validates lowercase Base32 secret', () {
      const lowercaseSecret = 'jbswy3dpehpk3pxp';

      expect(totpService.validateSecret(lowercaseSecret), isTrue);
    });

    test('rejects secret with invalid characters', () {
      // 0, 1, 8, 9 are not valid Base32 characters
      const invalidSecret = 'JBSWY3DPEHPK01289';

      expect(totpService.validateSecret(invalidSecret), isFalse);
    });

    test('rejects empty secret', () {
      expect(totpService.validateSecret(''), isFalse);
    });

    test('rejects secret with special characters', () {
      const invalidSecret = 'JBSWY3DP@#\$%^&*()';

      expect(totpService.validateSecret(invalidSecret), isFalse);
    });
  });

  group('TotpService - parseSecretFromQR', () {
    test('parses valid otpauth:// QR code', () {
      const qrData =
          'otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example';

      final secret = totpService.parseSecretFromQR(qrData);

      expect(secret, equals('JBSWY3DPEHPK3PXP'));
    });

    test('parses QR code with minimal format', () {
      const qrData = 'otpauth://totp/MyApp?secret=JBSWY3DPEHPK3PXP';

      final secret = totpService.parseSecretFromQR(qrData);

      expect(secret, equals('JBSWY3DPEHPK3PXP'));
    });

    test('parses QR code with additional parameters', () {
      const qrData =
          'otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA1&digits=6&period=30';

      final secret = totpService.parseSecretFromQR(qrData);

      expect(secret, equals('JBSWY3DPEHPK3PXP'));
    });

    test('throws FormatException for invalid protocol', () {
      const qrData = 'https://example.com?secret=JBSWY3DPEHPK3PXP';

      expect(
        () => totpService.parseSecretFromQR(qrData),
        throwsFormatException,
      );
    });

    test('throws FormatException for missing secret parameter', () {
      const qrData = 'otpauth://totp/Example:user@example.com?issuer=Example';

      expect(
        () => totpService.parseSecretFromQR(qrData),
        throwsFormatException,
      );
    });

    test('throws FormatException for empty secret parameter', () {
      const qrData =
          'otpauth://totp/Example:user@example.com?secret=&issuer=Example';

      expect(
        () => totpService.parseSecretFromQR(qrData),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid Base32 secret in QR', () {
      const qrData = 'otpauth://totp/Example?secret=INVALID01289';

      expect(
        () => totpService.parseSecretFromQR(qrData),
        throwsFormatException,
      );
    });
  });
}
