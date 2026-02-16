import '../domain/entry.dart';

/// Data model for Entry with JSON serialization
class EntryModel {
  final String id;
  final String encryptedData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EntryModel({
    required this.id,
    required this.encryptedData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encryptedData': encryptedData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a model from JSON
  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      encryptedData: json['encryptedData'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts domain Entry to EntryModel (requires encrypted data)
  factory EntryModel.fromDomain(Entry entry, String encryptedData) {
    return EntryModel(
      id: entry.id,
      encryptedData: encryptedData,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}

/// Helper class for serializing/deserializing Entry data before encryption
class EntryData {
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final List<String> categories;
  final bool isFavorite;
  final String? totpSecret;
  final List<PasswordHistoryData> passwordHistory;
  final int accessCount;

  const EntryData({
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    required this.categories,
    required this.isFavorite,
    this.totpSecret,
    required this.passwordHistory,
    required this.accessCount,
  });

  /// Converts to JSON (to be encrypted)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'categories': categories,
      'isFavorite': isFavorite,
      'totpSecret': totpSecret,
      'passwordHistory': passwordHistory.map((h) => h.toJson()).toList(),
      'accessCount': accessCount,
    };
  }

  /// Creates from JSON (after decryption)
  factory EntryData.fromJson(Map<String, dynamic> json) {
    return EntryData(
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String?,
      notes: json['notes'] as String?,
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      isFavorite: json['isFavorite'] as bool,
      totpSecret: json['totpSecret'] as String?,
      passwordHistory: (json['passwordHistory'] as List<dynamic>)
          .map((h) => PasswordHistoryData.fromJson(h as Map<String, dynamic>))
          .toList(),
      accessCount: json['accessCount'] as int? ?? 0,
    );
  }

  /// Creates from domain Entry
  factory EntryData.fromDomain(Entry entry) {
    return EntryData(
      title: entry.title,
      username: entry.username,
      password: entry.password,
      url: entry.url,
      notes: entry.notes,
      categories: entry.categories,
      isFavorite: entry.isFavorite,
      totpSecret: entry.totpSecret,
      passwordHistory: entry.passwordHistory
          .map((h) => PasswordHistoryData.fromDomain(h))
          .toList(),
      accessCount: entry.accessCount,
    );
  }

  /// Converts to domain Entry
  Entry toDomain(String id, DateTime createdAt, DateTime updatedAt) {
    return Entry(
      id: id,
      title: title,
      username: username,
      password: password,
      url: url,
      notes: notes,
      categories: categories,
      isFavorite: isFavorite,
      totpSecret: totpSecret,
      passwordHistory: passwordHistory.map((h) => h.toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      accessCount: accessCount,
    );
  }
}

/// Data model for PasswordHistory with JSON serialization
class PasswordHistoryData {
  final String password;
  final DateTime changedAt;

  const PasswordHistoryData({required this.password, required this.changedAt});

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {'password': password, 'changedAt': changedAt.toIso8601String()};
  }

  /// Creates from JSON
  factory PasswordHistoryData.fromJson(Map<String, dynamic> json) {
    return PasswordHistoryData(
      password: json['password'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
    );
  }

  /// Creates from domain PasswordHistory
  factory PasswordHistoryData.fromDomain(PasswordHistory history) {
    return PasswordHistoryData(
      password: history.password,
      changedAt: history.changedAt,
    );
  }

  /// Converts to domain PasswordHistory
  PasswordHistory toDomain() {
    return PasswordHistory(password: password, changedAt: changedAt);
  }
}
