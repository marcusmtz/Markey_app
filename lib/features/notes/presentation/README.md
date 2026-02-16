# Secure Notes Presentation Layer

This directory contains the presentation layer for the Secure Notes feature.

## Components

### Providers
- `NotesProvider`: Manages the state of secure notes, including loading, searching, and deleting notes.

### Screens
- `NotesListScreen`: Displays a list of all secure notes with search functionality.
- `NoteEditorScreen`: Allows creating and editing secure notes with file attachments.

### Widgets
- `NoteCard`: Card widget for displaying a note in the list with swipe actions.

## Integration

To integrate the Secure Notes feature into your app:

### 1. Add the provider to your app

In `main.dart`, add the `NotesProvider` to your `MultiProvider`:

```dart
import 'features/notes/data/secure_note_repository_impl.dart';
import 'features/notes/domain/secure_note_repository.dart';
import 'features/notes/presentation/providers/notes_provider.dart';

// In your MultiProvider:
providers: [
  // ... other providers ...
  
  // Secure Note Repository
  Provider<SecureNoteRepository>(
    create: (context) => SecureNoteRepositoryImpl(
      encryptionService: context.read<EncryptionService>(),
      storageService: context.read<SecureStorageService>(),
      masterKey: 'your_master_key_here', // Get from auth
    ),
  ),
  
  // Notes Provider
  ChangeNotifierProvider<NotesProvider>(
    create: (context) => NotesProvider(
      repository: context.read<SecureNoteRepository>(),
    ),
  ),
]
```

### 2. Navigate to the Notes screen

From any screen in your app:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NotesListScreen(),
  ),
);
```

### 3. Features

- **Create Note**: Tap the FAB (+) button to create a new note
- **Edit Note**: Tap on any note card to edit it
- **Delete Note**: Swipe left on a note card to reveal the delete action
- **Search**: Tap the search icon in the app bar to search notes by title or content
- **Attach Files**: In the editor, tap "Attach File" to add files up to 5MB
- **Remove Files**: Tap the X icon on any attached file to remove it

## File Attachments

The feature supports attaching files up to 5MB in size. Files are:
- Encrypted before storage
- Stored securely alongside the note
- Can be removed individually
- Displayed with file name and size

## Animations

The screens include:
- Staggered list animations for notes
- Fade and slide animations for UI elements
- Shimmer loading effect
- Smooth transitions between screens

## Requirements Implemented

This implementation satisfies:
- Requirement 9.1: Create secure notes with title and content
- Requirement 9.3: Attach files (max 5MB) with encryption
- Requirement 9.5: Search within note content
