import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/services/auto_lock_service.dart';
import 'core/services/auto_lock_service_impl.dart';
import 'core/services/clipboard_service.dart';
import 'core/services/clipboard_service_impl.dart';
import 'core/services/encryption_service.dart';
import 'core/services/encryption_service_impl.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/secure_storage_service_impl.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/auth_service_impl.dart';
import 'features/auth/domain/auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/generator/data/password_generator_service_impl.dart';
import 'features/generator/domain/password_generator_service.dart';
import 'features/generator/presentation/providers/password_generator_provider.dart';
import 'features/notes/data/secure_note_repository_impl.dart';
import 'features/notes/domain/secure_note_repository.dart';
import 'features/notes/presentation/providers/notes_provider.dart';
import 'features/security/data/security_analyzer_service_impl.dart';
import 'features/security/domain/security_analyzer_service.dart';
import 'features/security/presentation/providers/security_provider.dart';
import 'features/settings/data/settings_repository_impl.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/vault/data/category_repository_impl.dart';
import 'features/vault/data/vault_repository_impl.dart';
import 'features/vault/domain/category_repository.dart';
import 'features/vault/domain/vault_repository.dart';
import 'features/vault/presentation/providers/category_provider.dart';
import 'features/vault/presentation/providers/vault_provider.dart';

void main() {
  runApp(const MarkeyApp());
}

class MarkeyApp extends StatelessWidget {
  const MarkeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Services
        Provider<SecureStorageService>(
          create: (_) => SecureStorageServiceImpl(),
        ),
        Provider<EncryptionService>(create: (_) => EncryptionServiceImpl()),
        Provider<ClipboardService>(create: (_) => ClipboardServiceImpl()),
        Provider<AutoLockService>(
          create: (_) => AutoLockServiceImpl(),
          dispose: (_, service) => service.dispose(),
        ),

        // Auth Service
        Provider<AuthService>(
          create: (context) => AuthServiceImpl(
            context.read<SecureStorageService>(),
            LocalAuthentication(),
          ),
        ),

        // Password Generator Service
        Provider<PasswordGeneratorService>(
          create: (_) => PasswordGeneratorServiceImpl(),
        ),

        // Security Analyzer Service
        Provider<SecurityAnalyzerService>(
          create: (_) => SecurityAnalyzerServiceImpl(),
        ),

        // Vault Repository - initialized with temporary key
        // In production, this should be initialized after authentication
        Provider<VaultRepository>(
          create: (context) => VaultRepositoryImpl(
            encryptionService: context.read<EncryptionService>(),
            storageService: context.read<SecureStorageService>(),
            masterKey: 'temporary_master_key', // TODO: Set from auth
          ),
        ),

        // Category Repository
        Provider<CategoryRepository>(
          create: (context) => CategoryRepositoryImpl(
            encryptionService: context.read<EncryptionService>(),
            storageService: context.read<SecureStorageService>(),
            vaultRepository: context.read<VaultRepository>(),
            masterKey: 'temporary_master_key', // TODO: Set from auth
          ),
        ),

        // Secure Note Repository
        Provider<SecureNoteRepository>(
          create: (context) => SecureNoteRepositoryImpl(
            encryptionService: context.read<EncryptionService>(),
            storageService: context.read<SecureStorageService>(),
            masterKey: 'temporary_master_key', // TODO: Set from auth
          ),
        ),

        // Settings Repository
        Provider<SettingsRepository>(
          create: (context) => SettingsRepositoryImpl(
            context.read<SecureStorageService>(),
            context.read<EncryptionService>(),
            context.read<AuthService>(),
          ),
        ),

        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),

        // Auth Provider with AutoLockService integration
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            autoLockService: context.read<AutoLockService>(),
          )..initialize(),
        ),

        // Vault Provider - initialized with repository
        ChangeNotifierProvider<VaultProvider>(
          create: (context) =>
              VaultProvider(repository: context.read<VaultRepository>()),
        ),

        // Category Provider
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) =>
              CategoryProvider(repository: context.read<CategoryRepository>()),
        ),

        // Password Generator Provider
        ChangeNotifierProvider<PasswordGeneratorProvider>(
          create: (context) => PasswordGeneratorProvider(
            context.read<PasswordGeneratorService>(),
          ),
        ),

        // Security Provider
        ChangeNotifierProvider<SecurityProvider>(
          create: (context) => SecurityProvider(
            securityService: context.read<SecurityAnalyzerService>(),
            vaultRepository: context.read<VaultRepository>(),
          ),
        ),

        // Notes Provider
        ChangeNotifierProvider<NotesProvider>(
          create: (context) =>
              NotesProvider(repository: context.read<SecureNoteRepository>()),
        ),

        // Settings Provider with ThemeProvider and AutoLockService integration
        ChangeNotifierProxyProvider2<
          ThemeProvider,
          AutoLockService,
          SettingsProvider
        >(
          create: (context) => SettingsProvider(
            repository: context.read<SettingsRepository>(),
            themeProvider: context.read<ThemeProvider>(),
            autoLockService: context.read<AutoLockService>(),
          ),
          update: (context, themeProvider, autoLockService, previous) =>
              previous ??
              SettingsProvider(
                repository: context.read<SettingsRepository>(),
                themeProvider: themeProvider,
                autoLockService: autoLockService,
              ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Markey Password Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: RouteNames.onboarding,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

/// Initializes the app and determines which screen to show
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    // Wait for settings to load first
    final settingsProvider = context.read<SettingsProvider>();
    // Settings are loaded in constructor, but we need to wait for it to complete
    while (settingsProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Check if user has already set up master password/PIN
    final authService = context.read<AuthService>();
    final hasSetup = await authService.hasSetup();

    setState(() {
      _isFirstTime = !hasSetup;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to appropriate screen based on setup status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        if (_isFirstTime) {
          Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
        } else {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Gate that shows vault or login based on authentication status
class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Navigate based on authentication status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            if (authProvider.isAuthenticated) {
              Navigator.of(context).pushReplacementNamed(RouteNames.vault);
            } else {
              Navigator.of(context).pushReplacementNamed(RouteNames.login);
            }
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
