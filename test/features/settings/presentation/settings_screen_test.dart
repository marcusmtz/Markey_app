import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markey_app/core/services/encryption_service_impl.dart';
import 'package:markey_app/core/theme/app_theme.dart';
import 'package:markey_app/features/auth/data/auth_service_impl.dart';
import 'package:markey_app/features/backup/data/backup_service_impl.dart';
import 'package:markey_app/features/settings/data/settings_repository_impl.dart';
import 'package:markey_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:markey_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:markey_app/features/vault/data/vault_repository_impl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/mock_secure_storage.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late MockSecureStorage storage;
    late EncryptionServiceImpl encryptionService;
    late AuthServiceImpl authService;
    late SettingsRepositoryImpl settingsRepository;
    late VaultRepositoryImpl vaultRepository;
    late BackupServiceImpl backupService;

    setUp(() {
      storage = MockSecureStorage();
      encryptionService = EncryptionServiceImpl();
      authService = AuthServiceImpl(storage, LocalAuthentication());
      settingsRepository = SettingsRepositoryImpl(
        storage,
        encryptionService,
        authService,
      );
      vaultRepository = VaultRepositoryImpl(storage, encryptionService);
      backupService = BackupServiceImpl(
        vaultRepository,
        settingsRepository,
        encryptionService,
      );
    });

    testWidgets('should render settings screen with all sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(repository: settingsRepository),
            ),
            Provider.value(value: backupService),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Configuración'), findsOneWidget);

      // Verify security section
      expect(find.text('Seguridad'), findsOneWidget);
      expect(find.text('Bloqueo automático'), findsOneWidget);
      expect(find.text('Autenticación biométrica'), findsOneWidget);
      expect(find.text('Limpieza de portapapeles'), findsOneWidget);

      // Verify authentication section
      expect(find.text('Autenticación'), findsOneWidget);
      expect(find.text('Cambiar contraseña maestra'), findsOneWidget);
      expect(find.text('Cambiar PIN maestro'), findsOneWidget);

      // Verify appearance section
      expect(find.text('Apariencia'), findsOneWidget);
      expect(find.text('Tema'), findsOneWidget);

      // Verify backup section
      expect(find.text('Respaldo y Restauración'), findsOneWidget);
      expect(find.text('Crear respaldo'), findsOneWidget);
      expect(find.text('Restaurar respaldo'), findsOneWidget);

      // Verify about section
      expect(find.text('Acerca de'), findsOneWidget);
      expect(find.text('Versión'), findsOneWidget);
    });

    testWidgets('should show theme selector dialog when tapping theme option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(repository: settingsRepository),
            ),
            Provider.value(value: backupService),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on theme option
      await tester.tap(find.text('Tema'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Seleccionar tema'), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(find.text('Automático'), findsOneWidget);
    });

    testWidgets('should toggle biometrics switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(repository: settingsRepository),
            ),
            Provider.value(value: backupService),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the biometrics switch
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // Get initial state
      final initialSwitch = tester.widget<Switch>(switchFinder);
      final initialValue = initialSwitch.value;

      // Tap the switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify state changed
      final updatedSwitch = tester.widget<Switch>(switchFinder);
      expect(updatedSwitch.value, !initialValue);
    });
  });
}
