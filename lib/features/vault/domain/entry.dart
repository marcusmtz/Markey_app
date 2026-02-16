/// Domain entity representing a password entry in the vault
class Entry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final List<String> categories;
  final bool isFavorite;
  final String? totpSecret;
  final List<PasswordHistory> passwordHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int accessCount;

  const Entry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    this.categories = const [],
    this.isFavorite = false,
    this.totpSecret,
    this.passwordHistory = const [],
    required this.createdAt,
    required this.updatedAt,
    this.accessCount = 0,
  });

  /// Creates a copy of this entry with the given fields replaced
  Entry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    List<String>? categories,
    bool? isFavorite,
    String? totpSecret,
    List<PasswordHistory>? passwordHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? accessCount,
  }) {
    return Entry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
      totpSecret: totpSecret ?? this.totpSecret,
      passwordHistory: passwordHistory ?? this.passwordHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessCount: accessCount ?? this.accessCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Entry &&
        other.id == id &&
        other.title == title &&
        other.username == username &&
        other.password == password &&
        other.url == url &&
        other.notes == notes &&
        _listEquals(other.categories, categories) &&
        other.isFavorite == isFavorite &&
        other.totpSecret == totpSecret &&
        _listEquals(other.passwordHistory, passwordHistory) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.accessCount == accessCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      username,
      password,
      url,
      notes,
      Object.hashAll(categories),
      isFavorite,
      totpSecret,
      Object.hashAll(passwordHistory),
      createdAt,
      updatedAt,
      accessCount,
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

/// Represents a historical password entry
class PasswordHistory {
  final String password;
  final DateTime changedAt;

  const PasswordHistory({required this.password, required this.changedAt});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PasswordHistory &&
        other.password == password &&
        other.changedAt == changedAt;
  }

  @override
  int get hashCode => Object.hash(password, changedAt);
}
