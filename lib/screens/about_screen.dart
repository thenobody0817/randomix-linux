import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (opened || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(S.linkCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLicense(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.license),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Text(
              S.licenseText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(S.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(S.about)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/intro_icon.png',
                width: 116,
                height: 116,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              S.appName,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${S.aboutVersion} ${S.appVersion}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.introDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            S.linuxPortNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text(S.upstream),
                  subtitle: const Text(S.upstreamUrl),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _open(context, S.upstreamUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shop_outlined),
                  title: const Text('F-Droid'),
                  subtitle: const Text(S.fDroidUrl),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _open(context, S.fDroidUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(S.devName),
                  subtitle: const Text(S.devDescription),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text(S.license),
                  subtitle: const Text('MIT'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLicense(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
