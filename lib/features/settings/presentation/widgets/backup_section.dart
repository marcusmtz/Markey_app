import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/result.dart';
import '../../../backup/domain/backup_service.dart';
import 'settings_section.dart';
import 'settings_tile.dart';
import 'backup_password_dialog.dart';
import 'restore_backup_dialog.dart';

/// Section for backup and restore operations
class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Respaldo y Restauración',
      children: [
        SettingsTile(
          icon: Icons.backup,
          title: 'Crear respaldo',
          subtitle: 'Exportar datos cifrados',
          onTap: () => _showCreateBackupDialog(context),
        ),
        SettingsTile(
          icon: Icons.restore,
          title: 'Restaurar respaldo',
          subtitle: 'Importar datos desde archivo',
          onTap: () => _showRestoreBackupDialog(context),
        ),
      ],
    );
  }

  void _showCreateBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackupPasswordDialog(
        onSubmit: (password) async {
          final backupService = context.read<BackupService>();

          // Show loading
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }

          // Create backup
          final result = await backupService.createBackup(password);

          // Close loading
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          if (result.isSuccess && context.mounted) {
            final backupData = result.valueOrNull!;

            // Export backup
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filename = 'markey_backup_$timestamp.json';

            final exportResult = await backupService.exportBackup(
              backupData,
              filename,
            );

            if (exportResult.isSuccess && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Respaldo creado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    exportResult.errorOrNull?.message ??
                        'Error al exportar respaldo',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.errorOrNull?.message ?? 'Error al crear respaldo',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showRestoreBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RestoreBackupDialog(
        onSubmit: (filePath, password) async {
          final backupService = context.read<BackupService>();

          // Show loading
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }

          // Import backup
          final importResult = await backupService.importBackup(filePath);

          if (importResult.isFailure) {
            // Close loading
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    importResult.errorOrNull?.message ??
                        'Error al importar respaldo',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final backupData = importResult.valueOrNull!;

          // Restore backup
          final restoreResult = await backupService.restoreBackup(
            backupData,
            password,
          );

          // Close loading
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          if (restoreResult.isSuccess && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Respaldo restaurado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  restoreResult.errorOrNull?.message ??
                      'Error al restaurar respaldo',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
