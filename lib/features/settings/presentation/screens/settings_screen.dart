import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return AppScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            subtitle: const Text('Applies everywhere, instantly'),
            value: settings.isDark,
            onChanged: (_) => context.read<SettingsProvider>().toggleTheme(),
          ),
          const Divider(height: 32),
          Text('Background photo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: settings.backgroundImagePath != null
                ? ClipRRect(
                    key: ValueKey(settings.backgroundImagePath),
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(settings.backgroundImagePath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    key: const ValueKey('placeholder'),
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    alignment: Alignment.center,
                    child: const Text('No background set'),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<SettingsProvider>().pickBackgroundImage(),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Choose photo'),
                ),
              ),
              if (settings.backgroundImagePath != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => context.read<SettingsProvider>().clearBackgroundImage(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove',
                ),
              ],
            ],
          ),
          const Divider(height: 32),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('All tasks stay on this device. Export to back up or move them.'),
        ],
      ),
    );
  }
}
