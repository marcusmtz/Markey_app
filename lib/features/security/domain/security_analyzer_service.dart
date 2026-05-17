import '../../generator/domain/password_generator_service.dart';
import '../../vault/domain/entry.dart';

/// Abstract interface for security analysis operations
abstract class SecurityAnalyzerService {
  /// Analyzes a single password and returns its strength
  PasswordStrength analyzePassword(String password);

  /// Analyzes all entries in the vault and returns a comprehensive security report
  Future<SecurityReport> analyzeVault(List<Entry> entries);

  /// Checks if a password has been compromised using Have I Been Pwned API
  /// Uses k-anonymity to protect the password being checked
  Future<bool> isPasswordCompromised(String password);
}

/// Comprehensive security report for the vault
class SecurityReport {
  final int totalPasswords;
  final int weakPasswords;
  final int duplicatePasswords;
  final int compromisedPasswords;
  final double overallScore;
  final List<SecurityIssue> issues;

  const SecurityReport({
    required this.totalPasswords,
    required this.weakPasswords,
    required this.duplicatePasswords,
    required this.compromisedPasswords,
    required this.overallScore,
    required this.issues,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SecurityReport &&
        other.totalPasswords == totalPasswords &&
        other.weakPasswords == weakPasswords &&
        other.duplicatePasswords == duplicatePasswords &&
        other.compromisedPasswords == compromisedPasswords &&
        other.overallScore == overallScore &&
        _listEquals(other.issues, issues);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalPasswords,
      weakPasswords,
      duplicatePasswords,
      compromisedPasswords,
      overallScore,
      Object.hashAll(issues),
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Represents a specific security issue found during analysis
class SecurityIssue {
  final SecurityIssueType type;
  final String entryId;
  final String entryTitle;
  final String description;
  final SecurityIssueSeverity severity;

  const SecurityIssue({
    required this.type,
    required this.entryId,
    required this.entryTitle,
    required this.description,
    required this.severity,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SecurityIssue &&
        other.type == type &&
        other.entryId == entryId &&
        other.entryTitle == entryTitle &&
        other.description == description &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return Object.hash(type, entryId, entryTitle, description, severity);
  }
}

/// Types of security issues
enum SecurityIssueType {
  weakPassword,
  duplicatePassword,
  compromisedPassword,
  reusedPassword;

  String get description {
    switch (this) {
      case SecurityIssueType.weakPassword:
        return 'Weak Password';
      case SecurityIssueType.duplicatePassword:
        return 'Duplicate Password';
      case SecurityIssueType.compromisedPassword:
        return 'Compromised Password';
      case SecurityIssueType.reusedPassword:
        return 'Reused Password';
    }
  }
}

/// Severity levels for security issues
enum SecurityIssueSeverity {
  low,
  medium,
  high,
  critical;

  String get description {
    switch (this) {
      case SecurityIssueSeverity.low:
        return 'Low';
      case SecurityIssueSeverity.medium:
        return 'Medium';
      case SecurityIssueSeverity.high:
        return 'High';
      case SecurityIssueSeverity.critical:
        return 'Critical';
    }
  }
}
