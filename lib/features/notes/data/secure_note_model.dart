import '../domain/secure_note.dart';

/// Data model for SecureNote with JSON serialization
class SecureNoteModel {
  final String id;
  final String encryptedData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SecureNoteModel({
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
  factory SecureNoteModel.fromJson(Map<String, dynamic> json) {
    return SecureNoteModel(
      id: json['id'] as String,
      encryptedData: json['encryptedData'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts domain SecureNote to SecureNoteModel (requires encrypted data)
  factory SecureNoteModel.fromDomain(SecureNote note, String encryptedData) {
    return SecureNoteModel(
      id: note.id,
      encryptedData: encryptedData,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}

/// Helper class for serializing/deserializing SecureNote data before encryption
class SecureNoteData {
  final String title;
  final String content;
  final List<AttachedFileData> attachedFiles;

  const SecureNoteData({
    required this.title,
    required this.content,
    required this.attachedFiles,
  });

  /// Converts to JSON (to be encrypted)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'attachedFiles': attachedFiles.map((f) => f.toJson()).toList(),
    };
  }

  /// Creates from JSON (after decryption)
  factory SecureNoteData.fromJson(Map<String, dynamic> json) {
    return SecureNoteData(
      title: json['title'] as String,
      content: json['content'] as String,
      attachedFiles: (json['attachedFiles'] as List<dynamic>)
          .map((f) => AttachedFileData.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Creates from domain SecureNote
  factory SecureNoteData.fromDomain(SecureNote note) {
    return SecureNoteData(
      title: note.title,
      content: note.content,
      attachedFiles: note.attachedFiles
          .map((f) => AttachedFileData.fromDomain(f))
          .toList(),
    );
  }

  /// Converts to domain SecureNote
  SecureNote toDomain(String id, DateTime createdAt, DateTime updatedAt) {
    return SecureNote(
      id: id,
      title: title,
      content: content,
      attachedFiles: attachedFiles.map((f) => f.toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Data model for AttachedFile with JSON serialization
class AttachedFileData {
  final String id;
  final String fileName;
  final int sizeBytes;
  final DateTime attachedAt;

  const AttachedFileData({
    required this.id,
    required this.fileName,
    required this.sizeBytes,
    required this.attachedAt,
  });

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'sizeBytes': sizeBytes,
      'attachedAt': attachedAt.toIso8601String(),
    };
  }

  /// Creates from JSON
  factory AttachedFileData.fromJson(Map<String, dynamic> json) {
    return AttachedFileData(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      sizeBytes: json['sizeBytes'] as int,
      attachedAt: DateTime.parse(json['attachedAt'] as String),
    );
  }

  /// Creates from domain AttachedFile
  factory AttachedFileData.fromDomain(AttachedFile file) {
    return AttachedFileData(
      id: file.id,
      fileName: file.fileName,
      sizeBytes: file.sizeBytes,
      attachedAt: file.attachedAt,
    );
  }

  /// Converts to domain AttachedFile
  AttachedFile toDomain() {
    return AttachedFile(
      id: id,
      fileName: fileName,
      sizeBytes: sizeBytes,
      attachedAt: attachedAt,
    );
  }
}
