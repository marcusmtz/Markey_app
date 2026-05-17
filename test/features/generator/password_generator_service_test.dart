import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/features/generator/domain/password_generator_service.dart';
import 'package:markey_app/features/generator/data/password_generator_service_impl.dart';

void main() {
  late PasswordGeneratorService generatorService;

  setUp(() {
    generatorService = PasswordGeneratorServiceImpl();
  });

  group('PasswordGeneratorService', () {
    group('Configuration Validation', () {
      test('should accept valid configuration', () {
        const config = PasswordGeneratorConfig(
          length: 16,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: true,
        );

        expect(config.isValid, isTrue);
        expect(() => config.validate(), returnsNormally);
      });

      test('should reject length less than 8', () {
        const config = PasswordGeneratorConfig(length: 7);

        expect(config.isValid, isFalse);
        expect(() => config.validate(), throwsA(isA<ArgumentError>()));
      });

      test('should reject length greater than 64', () {
        const config = PasswordGeneratorConfig(length: 65);

        expect(config.isValid, isFalse);
        expect(() => config.validate(), throwsA(isA<ArgumentError>()));
      });

      test('should reject configuration with no character types selected', () {
        const config = PasswordGeneratorConfig(
          length: 16,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: false,
        );

        expect(config.isValid, isFalse);
        expect(() => config.validate(), throwsA(isA<ArgumentError>()));
      });

      test('should accept minimum length of 8', () {
        const config = PasswordGeneratorConfig(length: 8);

        expect(config.isValid, isTrue);
        expect(() => config.validate(), returnsNormally);
      });

      test('should accept maximum length of 64', () {
        const config = PasswordGeneratorConfig(length: 64);

        expect(config.isValid, isTrue);
        expect(() => config.validate(), returnsNormally);
      });
    });

    group('Password Generation', () {
      test('should generate password with correct length', () {
        const config = PasswordGeneratorConfig(length: 16);
        final password = generatorService.generate(config);

        expect(password.length, equals(16));
      });

      test('should generate password with minimum length', () {
        const config = PasswordGeneratorConfig(length: 8);
        final password = generatorService.generate(config);

        expect(password.length, equals(8));
      });

      test('should generate password with maximum length', () {
        const config = PasswordGeneratorConfig(length: 64);
        final password = generatorService.generate(config);

        expect(password.length, equals(64));
      });

      test('should include uppercase when selected', () {
        const config = PasswordGeneratorConfig(
          length: 20,
          includeUppercase: true,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: false,
        );
        final password = generatorService.generate(config);

        expect(password, matches(RegExp(r'^[A-Z]+$')));
        expect(password.length, equals(20));
      });

      test('should include lowercase when selected', () {
        const config = PasswordGeneratorConfig(
          length: 20,
          includeUppercase: false,
          includeLowercase: true,
          includeNumbers: false,
          includeSymbols: false,
        );
        final password = generatorService.generate(config);

        expect(password, matches(RegExp(r'^[a-z]+$')));
        expect(password.length, equals(20));
      });

      test('should include numbers when selected', () {
        const config = PasswordGeneratorConfig(
          length: 20,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: true,
          includeSymbols: false,
        );
        final password = generatorService.generate(config);

        expect(password, matches(RegExp(r'^[0-9]+$')));
        expect(password.length, equals(20));
      });

      test('should include symbols when selected', () {
        const config = PasswordGeneratorConfig(
          length: 20,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: true,
        );
        final password = generatorService.generate(config);

        expect(
          password,
          matches(RegExp(r'^[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]+$')),
        );
        expect(password.length, equals(20));
      });

      test('should include at least one character from each selected type', () {
        const config = PasswordGeneratorConfig(
          length: 16,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: true,
        );
        final password = generatorService.generate(config);

        expect(password, contains(RegExp(r'[A-Z]')));
        expect(password, contains(RegExp(r'[a-z]')));
        expect(password, contains(RegExp(r'[0-9]')));
        expect(password, contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')));
      });

      test('should generate different passwords on each call', () {
        const config = PasswordGeneratorConfig(length: 16);
        final password1 = generatorService.generate(config);
        final password2 = generatorService.generate(config);

        expect(password1, isNot(equals(password2)));
      });

      test('should exclude specified characters', () {
        const config = PasswordGeneratorConfig(
          length: 20,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: false,
          excludeCharacters: 'O0Il1',
        );
        final password = generatorService.generate(config);

        expect(password, isNot(contains('O')));
        expect(password, isNot(contains('0')));
        expect(password, isNot(contains('I')));
        expect(password, isNot(contains('l')));
        expect(password, isNot(contains('1')));
      });

      test('should throw when configuration is invalid', () {
        const config = PasswordGeneratorConfig(
          length: 5, // Too short
        );

        expect(
          () => generatorService.generate(config),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw when no character types are selected', () {
        const config = PasswordGeneratorConfig(
          length: 16,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: false,
        );

        expect(
          () => generatorService.generate(config),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Password Strength Evaluation', () {
      test('should evaluate empty password as weak', () {
        final strength = generatorService.evaluateStrength('');
        expect(strength, equals(PasswordStrength.weak));
      });

      test('should evaluate short simple password as weak', () {
        final strength = generatorService.evaluateStrength('123456');
        expect(strength, equals(PasswordStrength.weak));
      });

      test('should evaluate simple password as weak', () {
        final strength = generatorService.evaluateStrength('password');
        expect(strength, equals(PasswordStrength.weak));
      });

      test(
        'should evaluate medium complexity password as medium or higher',
        () {
          final strength = generatorService.evaluateStrength('Password123');
          expect(
            strength.index,
            greaterThanOrEqualTo(PasswordStrength.medium.index),
          );
        },
      );

      test('should evaluate strong password as strong or very strong', () {
        final strength = generatorService.evaluateStrength('P@ssw0rd!2024');
        expect(
          strength.index,
          greaterThanOrEqualTo(PasswordStrength.strong.index),
        );
      });

      test('should evaluate very strong password as very strong', () {
        final strength = generatorService.evaluateStrength(
          'Xy9\$mK2#pL5@qR8!vN3%wT6^',
        );
        expect(strength, equals(PasswordStrength.veryStrong));
      });

      test('should return valid strength for any password', () {
        final testPasswords = [
          '123',
          'abc',
          'Password1',
          'P@ssw0rd!',
          'VeryLongAndComplexPassword123!@#',
        ];

        for (final password in testPasswords) {
          final strength = generatorService.evaluateStrength(password);
          expect([
            PasswordStrength.weak,
            PasswordStrength.medium,
            PasswordStrength.strong,
            PasswordStrength.veryStrong,
          ], contains(strength));
        }
      });

      test('should have correct strength descriptions', () {
        expect(PasswordStrength.weak.description, equals('Weak'));
        expect(PasswordStrength.medium.description, equals('Medium'));
        expect(PasswordStrength.strong.description, equals('Strong'));
        expect(PasswordStrength.veryStrong.description, equals('Very Strong'));
      });

      test('should have correct strength scores', () {
        expect(PasswordStrength.weak.score, equals(25));
        expect(PasswordStrength.medium.score, equals(50));
        expect(PasswordStrength.strong.score, equals(75));
        expect(PasswordStrength.veryStrong.score, equals(100));
      });
    });

    group('Generated Password Strength', () {
      test('should generate strong passwords with default config', () {
        const config = PasswordGeneratorConfig(length: 16);
        final password = generatorService.generate(config);
        final strength = generatorService.evaluateStrength(password);

        expect(
          strength.index,
          greaterThanOrEqualTo(PasswordStrength.strong.index),
        );
      });

      test('should generate very strong passwords with long length', () {
        const config = PasswordGeneratorConfig(length: 32);
        final password = generatorService.generate(config);
        final strength = generatorService.evaluateStrength(password);

        expect(strength, equals(PasswordStrength.veryStrong));
      });

      test('should generate weaker passwords with limited character types', () {
        const config = PasswordGeneratorConfig(
          length: 8,
          includeUppercase: false,
          includeLowercase: true,
          includeNumbers: false,
          includeSymbols: false,
        );
        final password = generatorService.generate(config);
        final strength = generatorService.evaluateStrength(password);

        // Should be weak or medium due to limited character set
        expect(
          strength.index,
          lessThanOrEqualTo(PasswordStrength.medium.index),
        );
      });
    });
  });
}
