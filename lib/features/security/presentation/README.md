# Security Analysis Presentation Layer

This directory contains the UI components for the security analysis feature.

## Components

### Screens

- **SecurityAnalysisScreen**: Main screen displaying vault security analysis with animated score chart, category cards, and issue list

### Providers

- **SecurityProvider**: State management for security analysis, handles vault analysis and issue filtering

### Widgets

- **SecurityScoreChart**: Animated circular chart displaying security score (0-100) with color-coded labels
- **SecurityCategoryCard**: Glassmorphic card showing security issue categories (weak, duplicate, compromised passwords)
- **SecurityIssueCard**: Glassmorphic card displaying individual security issues with severity indicators

## Features

- Animated security score visualization
- Staggered animations for category cards and issue list
- Glassmorphism effects on cards
- Pull-to-refresh functionality
- Shimmer loading states
- Error handling with retry
- Bottom sheet for filtered issue views
- Info dialog explaining security scores

## Navigation

To navigate to the security analysis screen:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const SecurityAnalysisScreen(),
  ),
);
```

## Provider Setup

The SecurityProvider requires SecurityAnalyzerService and VaultRepository:

```dart
ChangeNotifierProvider(
  create: (context) => SecurityProvider(
    securityService: context.read<SecurityAnalyzerService>(),
    vaultRepository: context.read<VaultRepository>(),
  ),
)
```

## Requirements Implemented

- **Requisito 8.2**: Display security summary with weak, duplicate, and compromised passwords
- **Requisito 8.4**: Suggest generating new passwords for weak entries
- **Requisito 15.1**: Smooth animations and transitions
- **Requisito 15.2**: Staggered animations for list items
