import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sound_service.dart';
import '../state/settings_controller.dart';
import '../strings.dart';
import '../theme/accent_colors.dart';
import '../widgets/blob_background.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _themeLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => S.themeSystem,
    AppThemeMode.dark => S.themeDark,
    AppThemeMode.light => S.themeLight,
  };

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final sound = context.read<SoundController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.settings),
        actions: [
          IconButton(
            tooltip: S.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlobBackground(
        enabled: settings.blob,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _section(context, S.customization),

            ListTile(
              title: const Text(S.themeName),
              subtitle: Text(
                S.themeDescription.replaceAll(
                  '%s',
                  _themeLabel(settings.themeMode),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: AppThemeMode.system,
                    label: Text(S.themeSystem),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.dark,
                    label: Text(S.themeDark),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.light,
                    label: Text(S.themeLight),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (values) =>
                    settings.setThemeMode(values.first),
              ),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text(S.amoledName),
              subtitle: Text(
                settings.amoled
                    ? S.amoledDescriptionOn
                    : S.amoledDescriptionOff,
              ),
              value: settings.amoled,
              onChanged: settings.setAmoled,
            ),

            ListTile(
              title: const Text(S.accentName),
              subtitle: Text(
                S.accentDescription.replaceAll('%s', settings.accent.label),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final accent in Accent.values)
                    _AccentSwatch(
                      accent: accent,
                      selected: settings.accent == accent,
                      onTap: () => settings.setAccent(accent),
                    ),
                ],
              ),
            ),

            SwitchListTile(
              title: const Text(S.blobName),
              subtitle: const Text(S.blobDescription),
              value: settings.blob,
              onChanged: settings.setBlob,
            ),

            _section(context, S.appBehavior),

            SwitchListTile(
              title: const Text(S.soundName),
              subtitle: Text(
                sound.unavailable
                    ? 'Audio backend unavailable on this system'
                    : settings.sound
                    ? S.soundDescriptionOn
                    : S.soundDescriptionOff,
              ),
              value: settings.sound,
              onChanged: sound.unavailable ? null : settings.setSound,
            ),
            SwitchListTile(
              title: const Text(S.hideDescriptionsName),
              subtitle: Text(
                settings.hideDescriptions
                    ? S.hideDescriptionsOn
                    : S.hideDescriptionsOff,
              ),
              value: settings.hideDescriptions,
              onChanged: settings.setHideDescriptions,
            ),
            SwitchListTile(
              title: const Text(S.allowEqualsName),
              subtitle: Text(
                settings.allowEquals ? S.allowEqualsOn : S.allowEqualsOff,
              ),
              value: settings.allowEquals,
              onChanged: settings.setAllowEquals,
            ),
            SwitchListTile(
              title: const Text(S.removeLastName),
              subtitle: Text(
                settings.removeLast ? S.removeLastOn : S.removeLastOff,
              ),
              value: settings.removeLast,
              onChanged: settings.setRemoveLast,
            ),
            SwitchListTile(
              title: const Text(S.rudeAnswersName),
              subtitle: Text(
                settings.rudeAnswers ? S.rudeAnswersOn : S.rudeAnswersOff,
              ),
              value: settings.rudeAnswers,
              onChanged: settings.setRudeAnswers,
            ),

            ListTile(
              leading: const Icon(Icons.keyboard_outlined),
              title: const Text(S.keyboardShortcuts),
              subtitle: const Text(S.keyboardHint),
            ),

            _section(context, S.about),
            ListTile(
              leading: const Icon(Icons.replay_outlined),
              title: const Text(S.showIntro),
              onTap: () async {
                await settings.resetIntro();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: const Text(S.resetSettings),
              onTap: () => _confirmReset(context, settings),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(S.about),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Future<void> _confirmReset(
    BuildContext context,
    SettingsController settings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.resetSettings),
        content: const Text(S.resetSettingsQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.resetSettings),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await settings.reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(S.settingsRestored),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final Accent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSystem = accent == Accent.system;
    final background = isSystem
        ? const SweepGradient(
            colors: [
              Color(0xFF3584E4),
              Color(0xFF3A944A),
              Color(0xFFC88800),
              Color(0xFFE62D42),
              Color(0xFF9141AC),
              Color(0xFF3584E4),
            ],
          )
        : null;
    final onColor =
        ThemeData.estimateBrightnessForColor(accent.swatch) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Tooltip(
      message: accent.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background == null ? accent.swatch : null,
            gradient: background,
            border: Border.all(
              color: selected ? scheme.onSurface : scheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(Icons.check, size: 22, color: onColor)
              : isSystem
              ? const Icon(Icons.auto_awesome, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
