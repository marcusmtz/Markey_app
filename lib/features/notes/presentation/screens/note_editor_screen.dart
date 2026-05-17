import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/secure_note.dart';
import '../../domain/secure_note_repository.dart';

/// Screen for creating and editing secure notes
class NoteEditorScreen extends StatefulWidget {
  final SecureNote? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  List<AttachedFile> _attachedFiles = [];
  List<_PendingFile> _pendingFiles = [];

  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _attachedFiles = List.from(widget.note!.attachedFiles);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size
        if (file.size > _maxFileSizeBytes) {
          if (mounted) {
            _showError('File size exceeds maximum limit of 5MB');
          }
          return;
        }

        if (file.bytes != null) {
          setState(() {
            _pendingFiles.add(
              _PendingFile(
                name: file.name,
                bytes: file.bytes!,
                size: file.size,
              ),
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick file: ${e.toString()}');
      }
    }
  }

  Future<void> _removeAttachedFile(AttachedFile file) async {
    if (widget.note == null) return;

    final confirmed = await _showConfirmDialog(
      'Remove File',
      'Are you sure you want to remove "${file.fileName}"?',
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final repository = context.read<SecureNoteRepository>();
    final result = await repository.removeAttachedFile(
      widget.note!.id,
      file.id,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      setState(() {
        _attachedFiles.removeWhere((f) => f.id == file.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('File removed')));
      }
    } else {
      if (mounted) {
        _showError(result.errorOrNull?.message ?? 'Failed to remove file');
      }
    }
  }

  void _removePendingFile(_PendingFile file) {
    setState(() {
      _pendingFiles.removeWhere((f) => f.name == file.name);
    });
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repository = context.read<SecureNoteRepository>();
    final now = DateTime.now();

    try {
      SecureNote note;

      if (widget.note == null) {
        // Create new note
        note = SecureNote(
          id: now.millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          attachedFiles: [],
          createdAt: now,
          updatedAt: now,
        );

        final createResult = await repository.createNote(note);
        if (createResult.isFailure) {
          throw Exception(
            createResult.errorOrNull?.message ?? 'Failed to create note',
          );
        }
        note = createResult.valueOrNull!;
      } else {
        // Update existing note
        note = widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          updatedAt: now,
        );

        final updateResult = await repository.updateNote(note);
        if (updateResult.isFailure) {
          throw Exception(
            updateResult.errorOrNull?.message ?? 'Failed to update note',
          );
        }
        note = updateResult.valueOrNull!;
      }

      // Attach pending files
      for (final pendingFile in _pendingFiles) {
        final attachResult = await repository.attachFile(
          noteId: note.id,
          fileName: pendingFile.name,
          fileData: pendingFile.bytes,
        );

        if (attachResult.isFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to attach ${pendingFile.name}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter note title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.sentences,
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 16),

                    // Content Field
                    TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: 'Content',
                            hintText: 'Enter note content',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          maxLines: 12,
                          minLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                        )
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 24),

                    // Attached Files Section
                    Text(
                      'Attached Files',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 12),

                    // Existing attached files
                    if (_attachedFiles.isNotEmpty) ...[
                      ..._attachedFiles.map(
                        (file) => _buildAttachedFileCard(
                          file.fileName,
                          file.sizeBytes,
                          () => _removeAttachedFile(file),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Pending files
                    if (_pendingFiles.isNotEmpty) ...[
                      ..._pendingFiles.map(
                        (file) => _buildPendingFileCard(
                          file.name,
                          file.size,
                          () => _removePendingFile(file),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Add File Button
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach File (Max 5MB)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(),

                    const SizedBox(height: 8),

                    // File size info
                    Text(
                      'Maximum file size: 5MB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAttachedFileCard(
    String fileName,
    int sizeBytes,
    VoidCallback onRemove,
  ) {
    final theme = Theme.of(context);
    final sizeKB = (sizeBytes / 1024).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.insert_drive_file,
          color: theme.colorScheme.primary,
        ),
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$sizeKB KB'),
        trailing: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildPendingFileCard(
    String fileName,
    int sizeBytes,
    VoidCallback onRemove,
  ) {
    final theme = Theme.of(context);
    final sizeKB = (sizeBytes / 1024).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: Icon(Icons.upload_file, color: theme.colorScheme.primary),
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$sizeKB KB (pending)'),
        trailing: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }
}

/// Helper class for pending file attachments
class _PendingFile {
  final String name;
  final Uint8List bytes;
  final int size;

  _PendingFile({required this.name, required this.bytes, required this.size});
}
