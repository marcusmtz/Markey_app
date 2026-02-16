/// Domain entity representing a secure note
class SecureNote {
  final String id;
  final String title;
  final String content;
  final List<AttachedFile> attachedFiles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SecureNote({
    required this.id,
    required this.title,
    required this.content,
    this.attachedFiles = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this note with the given fields replaced
  SecureNote copyWith({
    String? id,
    String? title,
    String? content,
    List<AttachedFile>? attachedFiles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecureNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SecureNote &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        _listEquals(other.attachedFiles, attachedFiles) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      Object.hashAll(attachedFiles),
      createdAt,
      updatedAt,
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

/// Represents an attached file in a secure note
class AttachedFile {
  final String id;
  final String fileName;
  final int sizeBytes;
  final DateTime attachedAt;

  const AttachedFile({
    required this.id,
    required this.fileName,
    required this.sizeBytes,
    required this.attachedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttachedFile &&
        other.id == id &&
        other.fileName == fileName &&
        other.sizeBytes == sizeBytes &&
        other.attachedAt == attachedAt;
  }

  @override
  int get hashCode => Object.hash(id, fileName, sizeBytes, attachedAt);
}
