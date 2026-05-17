import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/backup_section.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/change_pin_dialog.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector_dialog.dart';
import '../widgets/duration_selector_dialog.dart';

/// Settings screen with grouped configuration options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = provider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Security Section
              SettingsSection(
                title: 'Seguridad',
                children: [
                  SettingsTile(
                    icon: Icons.lock_clock,
                    title: 'Bloqueo automático',
                    subtitle: _formatDuration(settings.autoLockDuration),
                    onTap: () => _showAutoLockDurationDialog(context, provider),
                  ),
                  SettingsTile(
                    icon: Icons.fingerprint,
                    title: 'Autenticación biométrica',
                    subtitle: settings.biometricsEnabled
                        ? 'Activada'
                        : 'Desactivada',
                    trailing: Switch(
                      value: settings.biometricsEnabled,
                      onChanged: (value) {
                        provider.toggleBiometrics(value);
                      },
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.content_paste,
                    title: 'Limpieza de portapapeles',
                    subtitle: _formatDuration(settings.clipboardClearDuration),
                    onTap: () =>
                        _showClipboardDurationDialog(context, provider),
                  ),
                  SettingsTile(
                    icon: Icons.security,
                    title: 'Verificar contraseñas comprometidas',
                    subtitle: settings.breachCheckEnabled
                        ? 'Activada'
                        : 'Desactivada',
                    trailing: Switch(
                      value: settings.breachCheckEnabled,
                      onChanged: (value) {
                        provider.toggleBreachCheck(value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Authentication Section
              SettingsSection(
                title: 'Autenticación',
                children: [
                  SettingsTile(
                    icon: Icons.password,
                    title: 'Cambiar contraseña maestra',
                    subtitle: 'Actualizar contraseña de acceso',
                    onTap: () => _showChangePasswordDialog(context, provider),
                  ),
                  SettingsTile(
                    icon: Icons.pin,
                    title: 'Cambiar PIN maestro',
                    subtitle: 'Actualizar PIN de acceso',
                    onTap: () => _showChangePinDialog(context, provider),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Appearance Section
              SettingsSection(
                title: 'Apariencia',
                children: [
                  SettingsTile(
                    icon: Icons.palette,
                    title: 'Tema',
                    subtitle: _getThemeModeLabel(settings.themeMode),
                    onTap: () => _showThemeSelectorDialog(context, provider),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Backup Section
              const BackupSection(),

              const SizedBox(height: 24),

              // About Section
              SettingsSection(
                title: 'Acerca de',
                children: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Versión',
                    subtitle: '1.0.0',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.description,
                    title: 'Licencias',
                    subtitle: 'Ver licencias de código abierto',
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Markey Password Manager',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds} segundos';
    } else if (duration.inMinutes == 1) {
      return '1 minuto';
    } else {
      return '${duration.inMinutes} minutos';
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }

  void _showAutoLockDurationDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => DurationSelectorDialog(
        title: 'Bloqueo automático',
        currentDuration: provider.settings.autoLockDuration,
        options: const [
          Duration(seconds: 30),
          Duration(minutes: 1),
          Duration(minutes: 2),
          Duration(minutes: 5),
          Duration(minutes: 10),
          Duration(minutes: 30),
        ],
        onSelected: (duration) {
          provider.updateAutoLockDuration(duration);
        },
      ),
    );
  }

  void _showClipboardDurationDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => DurationSelectorDialog(
        title: 'Limpieza de portapapeles',
        currentDuration: provider.settings.clipboardClearDuration,
        options: const [
          Duration(seconds: 15),
          Duration(seconds: 30),
          Duration(seconds: 45),
          Duration(minutes: 1),
          Duration(minutes: 2),
        ],
        onSelected: (duration) {
          provider.updateClipboardClearDuration(duration);
        },
      ),
    );
  }

  void _showThemeSelectorDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectorDialog(
        currentTheme: provider.settings.themeMode,
        onSelected: (mode) {
          provider.updateThemeMode(mode);
        },
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    SettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onSubmit: (currentPassword, newPassword) async {
          final success = await provider.changeMasterPassword(
            currentPassword,
            newPassword,
          );

          if (context.mounted) {
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.errorMessage ?? 'Error al cambiar contraseña',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ChangePinDialog(
        onSubmit: (currentPin, newPin) async {
          final success = await provider.changeMasterPin(currentPin, newPin);

          if (context.mounted) {
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN actualizado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.errorMessage ?? 'Error al cambiar PIN',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
