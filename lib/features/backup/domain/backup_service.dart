import '../../../core/utils/result.dart';

/// Abstract interface for backup and restore operations
/// Manages encrypted backup creation and restoration of vault data
abstract class BackupService {
  /// Creates an encrypted backup of all vault data
  /// [masterPassword] - The master password used to encrypt the backup
  /// Returns a JSON string containing the encrypted backup data
  Future<Result<String>> createBackup(String masterPassword);

  /// Exports a backup to local storage
  /// [backupData] - The backup JSON string to export
  /// [path] - The file path where the backup should be saved
  Future<Result<void>> exportBackup(String backupData, String path);

  /// Imports a backup from a file
  /// [path] - The file path to import from
  /// Returns the backup JSON string
  Future<Result<String>> importBackup(String path);

  /// Restores vault data from an encrypted backup
  /// [backupData] - The backup JSON string to restore
  /// [masterPassword] - The master password used to decrypt the backup
  /// Validates password and handles corrupted backups without losing existing data
  Future<Result<void>> restoreBackup(String backupData, String masterPassword);
}
