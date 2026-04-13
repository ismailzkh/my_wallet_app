import 'package:flutter/material.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _autoBackup = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String _lastBackup = 'Today, 6:00 AM';

  Future<void> _doBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isBackingUp = false;
      _lastBackup = 'Just now';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup completed successfully')),
      );
    }
  }

  Future<void> _doRestore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with the backup. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRestoring = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data restored successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.cloud_done_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Backup',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastBackup,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Backup Settings',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.autorenew_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text('Auto Backup'),
              subtitle: const Text('Backup data automatically every day'),
              value: _autoBackup,
              onChanged: (val) => setState(() => _autoBackup = val),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Actions',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('Backup Now'),
                  subtitle: const Text('Save current data to backup'),
                  trailing: _isBackingUp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _isBackingUp ? null : _doBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.orange.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.cloud_download_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('Restore Backup'),
                  subtitle: const Text('Replace current data with backup'),
                  trailing: _isRestoring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _isRestoring ? null : _doRestore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}