/// Data model for backup with JSON serialization
/// Format: version, timestamp, salt, encrypted data
class BackupModel {
  final String version;
  final DateTime timestamp;
  final String salt;
  final String encryptedData;

  const BackupModel({
    required this.version,
    required this.timestamp,
    required this.salt,
    required this.encryptedData,
  });

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'salt': salt,
      'data': encryptedData,
    };
  }

  /// Creates a model from JSON
  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      version: json['version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      salt: json['salt'] as String,
      encryptedData: json['data'] as String,
    );
  }
}

/// Helper class for serializing vault data before encryption
class BackupData {
  final List<Map<String, dynamic>> entries;
  final Map<String, dynamic> settings;
  final List<Map<String, dynamic>> categories;

  const BackupData({
    required this.entries,
    required this.settings,
    required this.categories,
  });

  /// Converts to JSON (to be encrypted)
  Map<String, dynamic> toJson() {
    return {'entries': entries, 'settings': settings, 'categories': categories};
  }

  /// Creates from JSON (after decryption)
  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      settings: json['settings'] as Map<String, dynamic>,
      categories: (json['categories'] as List<dynamic>)
          .map((c) => c as Map<String, dynamic>)
          .toList(),
    );
  }
}
