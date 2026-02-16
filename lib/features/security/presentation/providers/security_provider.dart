import 'package:flutter/foundation.dart';
import '../../domain/security_analyzer_service.dart';
import '../../../vault/domain/vault_repository.dart';
import '../../../../core/utils/result.dart';

/// Provider for managing security analysis state
class SecurityProvider extends ChangeNotifier {
  final SecurityAnalyzerService _securityService;
  final VaultRepository _vaultRepository;

  SecurityProvider({
    required SecurityAnalyzerService securityService,
    required VaultRepository vaultRepository,
  }) : _securityService = securityService,
       _vaultRepository = vaultRepository;

  SecurityReport? _report;
  bool _isAnalyzing = false;
  String? _errorMessage;

  SecurityReport? get report => _report;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  bool get hasReport => _report != null;

  /// Analyze vault security
  Future<void> analyzeVault() async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get all entries from vault
      final entriesResult = await _vaultRepository.getAllEntries();

      if (entriesResult.isSuccess) {
        final entries = entriesResult.valueOrNull ?? [];
        _report = await _securityService.analyzeVault(entries);
      } else {
        _errorMessage =
            entriesResult.errorOrNull?.message ??
            'Failed to load entries for analysis';
      }
    } catch (e) {
      _errorMessage = 'Analysis failed: ${e.toString()}';
    }

    _isAnalyzing = false;
    notifyListeners();
  }

  /// Get issues by type
  List<SecurityIssue> getIssuesByType(SecurityIssueType type) {
    if (_report == null) return [];
    return _report!.issues.where((issue) => issue.type == type).toList();
  }

  /// Get issues by severity
  List<SecurityIssue> getIssuesBySeverity(SecurityIssueSeverity severity) {
    if (_report == null) return [];
    return _report!.issues
        .where((issue) => issue.severity == severity)
        .toList();
  }

  /// Clear current report
  void clearReport() {
    _report = null;
    _errorMessage = null;
    notifyListeners();
  }
}
