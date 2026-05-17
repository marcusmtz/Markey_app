# Password Generator Presentation Layer

## Overview

This directory contains the presentation layer for the password generator feature, providing a modern and intuitive UI for generating secure passwords.

## Components

### Screens

#### `password_generator_screen.dart`
Full-screen password generator with advanced configuration options.

**Features:**
- Glassmorphic container with password display
- Animated slider for password length (8-64 characters)
- Switches for character type selection (uppercase, lowercase, numbers, symbols)
- Real-time password strength indicator
- Regenerate button with rotation animation
- Copy to clipboard functionality
- Information dialog explaining strength levels

**Animations:**
- Fade-in and slide animations on screen load
- Rotation animation on regenerate button
- Staggered animations for character type switches
- Scale animation for action buttons

**Requirements Implemented:**
- **4.2**: Configurable password length (8-64 characters)
- **4.3**: Character type selection (uppercase, lowercase, numbers, symbols)
- **4.5**: Real-time password strength display
- **15.1**: Modern UI with smooth animations

### Providers

#### `password_generator_provider.dart`
State management provider for password generator functionality.

**Features:**
- Manages password generation configuration
- Generates passwords using PasswordGeneratorService
- Evaluates password strength
- Provides methods for updating configuration
- Notifies listeners on state changes

**Methods:**
- `generatePassword()`: Generates a new password with current config
- `updateConfig()`: Updates configuration and regenerates
- `updateLength()`: Updates password length
- `toggleUppercase()`, `toggleLowercase()`, `toggleNumbers()`, `toggleSymbols()`: Toggle character types
- `evaluatePasswordStrength()`: Evaluates strength of any password

## Usage

### Navigation

Navigate to the password generator screen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PasswordGeneratorScreen(),
  ),
);
```

Or use it as a dialog and receive the generated password:

```dart
final password = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (context) => const PasswordGeneratorScreen(),
  ),
);

if (password != null) {
  // Use the generated password
}
```

### Provider Setup

Ensure the PasswordGeneratorService is provided in the widget tree:

```dart
MultiProvider(
  providers: [
    Provider<PasswordGeneratorService>(
      create: (_) => PasswordGeneratorServiceImpl(),
    ),
    // ... other providers
  ],
  child: MyApp(),
)
```

## Design Patterns

### Glassmorphism
The screen uses glassmorphic containers for a modern, frosted-glass effect:
- Semi-transparent background with blur
- Gradient borders
- Layered visual hierarchy

### Animations
Multiple animation types create a fluid user experience:
- **Fade-in**: Smooth appearance of elements
- **Slide**: Directional entry animations
- **Rotation**: Regenerate button spins on click
- **Scale**: Buttons grow slightly on appearance
- **Staggered**: Sequential animations for list items

### Responsive Design
The screen adapts to different screen sizes:
- Scrollable content for smaller screens
- Flexible layouts with proper spacing
- Touch-friendly button sizes

## Accessibility

- Semantic labels for all interactive elements
- Sufficient color contrast for text
- Touch targets meet minimum size requirements
- Screen reader support through proper widget structure

## Testing

Test the password generator screen:

```dart
testWidgets('Password generator screen displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Provider<PasswordGeneratorService>(
        create: (_) => PasswordGeneratorServiceImpl(),
        child: const PasswordGeneratorScreen(),
      ),
    ),
  );

  expect(find.text('Password Generator'), findsOneWidget);
  expect(find.byType(Slider), findsOneWidget);
  expect(find.byType(Switch), findsNWidgets(4));
});
```

## Future Enhancements

Potential improvements for future iterations:
- Password history (recently generated passwords)
- Custom character exclusion
- Password templates/presets
- Export/share functionality
- Pronounceable password option
- Passphrase generation
