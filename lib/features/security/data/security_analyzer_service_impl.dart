import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../generator/domain/password_generator_service.dart';
import '../../vault/domain/entry.dart';
import '../domain/security_analyzer_service.dart';

/// Implementation of SecurityAnalyzerService
class SecurityAnalyzerServiceImpl implements SecurityAnalyzerService {
  final http.Client? _httpClient;

  SecurityAnalyzerServiceImpl({http.Client? httpClient})
    : _httpClient = httpClient;

  @override
  PasswordStrength analyzePassword(String password) {
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

  @override
  Future<SecurityReport> analyzeVault(List<Entry> entries) async {
    if (entries.isEmpty) {
      return const SecurityReport(
        totalPasswords: 0,
        weakPasswords: 0,
        duplicatePasswords: 0,
        compromisedPasswords: 0,
        overallScore: 100.0,
        issues: [],
      );
    }

    final issues = <SecurityIssue>[];
    var weakCount = 0;
    var compromisedCount = 0;

    // Analyze each password for strength
    for (final entry in entries) {
      final strength = analyzePassword(entry.password);

      if (strength == PasswordStrength.weak) {
        weakCount++;
        issues.add(
          SecurityIssue(
            type: SecurityIssueType.weakPassword,
            entryId: entry.id,
            entryTitle: entry.title,
            description: 'Password is weak and should be strengthened',
            severity: SecurityIssueSeverity.high,
          ),
        );
      }
    }

    // Detect duplicate passwords
    final duplicateCount = _detectDuplicates(entries, issues);

    // Calculate overall score (0-100)
    final score = _calculateOverallScore(
      entries.length,
      weakCount,
      duplicateCount,
      compromisedCount,
    );

    return SecurityReport(
      totalPasswords: entries.length,
      weakPasswords: weakCount,
      duplicatePasswords: duplicateCount,
      compromisedPasswords: compromisedCount,
      overallScore: score,
      issues: issues,
    );
  }

  @override
  Future<bool> isPasswordCompromised(String password) async {
    try {
      // Hash the password using SHA-1
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes);
      final hash = digest.toString().toUpperCase();

      // Use k-anonymity: send only first 5 characters of hash
      final prefix = hash.substring(0, 5);
      final suffix = hash.substring(5);

      // Query Have I Been Pwned API
      final client = _httpClient ?? http.Client();
      final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');

      final response = await client.get(url);

      if (response.statusCode == 200) {
        // Check if our suffix appears in the response
        final lines = response.body.split('\n');
        for (final line in lines) {
          final parts = line.split(':');
          if (parts.isNotEmpty && parts[0].trim() == suffix) {
            return true; // Password found in breach database
          }
        }
        return false; // Password not found
      } else {
        // If API call fails, return false (assume not compromised)
        return false;
      }
    } catch (e) {
      // If any error occurs, return false (assume not compromised)
      return false;
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

  /// Detects duplicate passwords and adds issues
  /// Returns the count of duplicate passwords
  int _detectDuplicates(List<Entry> entries, List<SecurityIssue> issues) {
    final passwordMap = <String, List<Entry>>{};

    // Group entries by password
    for (final entry in entries) {
      if (!passwordMap.containsKey(entry.password)) {
        passwordMap[entry.password] = [];
      }
      passwordMap[entry.password]!.add(entry);
    }

    var duplicateCount = 0;

    // Find passwords used more than once
    for (final passwordEntries in passwordMap.values) {
      if (passwordEntries.length > 1) {
        duplicateCount += passwordEntries.length;

        // Add issue for each entry with duplicate password
        for (final entry in passwordEntries) {
          issues.add(
            SecurityIssue(
              type: SecurityIssueType.duplicatePassword,
              entryId: entry.id,
              entryTitle: entry.title,
              description:
                  'Password is used in ${passwordEntries.length} entries',
              severity: SecurityIssueSeverity.high,
            ),
          );
        }
      }
    }

    return duplicateCount;
  }

  /// Calculates overall security score (0-100)
  double _calculateOverallScore(
    int total,
    int weak,
    int duplicate,
    int compromised,
  ) {
    if (total == 0) {
      return 100.0;
    }

    // Calculate percentage of problematic passwords
    final weakPercentage = (weak / total) * 100;
    final duplicatePercentage = (duplicate / total) * 100;
    final compromisedPercentage = (compromised / total) * 100;

    // Weight the issues (weak: 30%, duplicate: 40%, compromised: 30%)
    final deduction =
        (weakPercentage * 0.3) +
        (duplicatePercentage * 0.4) +
        (compromisedPercentage * 0.3);

    // Calculate score (100 - deduction)
    final score = 100.0 - deduction;

    // Ensure score is in valid range [0, 100]
    return score.clamp(0.0, 100.0);
  }
}
