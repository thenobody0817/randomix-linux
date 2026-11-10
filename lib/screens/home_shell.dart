import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';
import '../state/tool_shortcuts.dart';
import '../strings.dart';
import '../widgets/blob_background.dart';
import 'coin_screen.dart';
import 'dice_screen.dart';
import 'magic_ball_screen.dart';
import 'roulette_screen.dart';
import 'settings_screen.dart';

/// The four tools plus the floating navigation, switching between a bottom bar
/// and a side rail exactly like the Android app switches between bar and rail.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _pageKeys = ['roulette', 'coin', 'dice', 'magicBall'];
  static const _titles = [S.roulette, S.coin, S.dice, S.magicBall];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    final last = _pageKeys.indexOf(settings.lastPage);
    if (last > 0) _index = last;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (settings.lastPageSettings) {
        await _openSettings();
      }
      settings.setLastPage(_pageKeys[_index], settingsOpen: false);
    });
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    context.read<SettingsController>().setLastPage(
      _pageKeys[index],
      settingsOpen: false,
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    if (!mounted) return;
    context.read<SettingsController>().setLastPage(
      _pageKeys[_index],
      settingsOpen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;

    final pages = IndexedStack(
      index: _index,
      children: const [
        RouletteScreen(),
        CoinScreen(),
        DiceScreen(),
        MagicBallScreen(),
      ],
    );

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final extended = constraints.maxWidth >= 1020;

        if (!wide) {
          return Column(
            children: [
              Expanded(child: pages),
              NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _select,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.pie_chart_outline),
                    selectedIcon: Icon(Icons.pie_chart),
                    label: S.roulette,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.monetization_on_outlined),
                    selectedIcon: Icon(Icons.monetization_on),
                    label: S.coin,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.casino_outlined),
                    selectedIcon: Icon(Icons.casino),
                    label: S.dice,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome),
                    label: S.magicBall,
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              extended: extended,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              minExtendedWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/icon_512.png',
                    width: 44,
                    height: 44,
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      tooltip: S.settings,
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.pie_chart_outline),
                  selectedIcon: Icon(Icons.pie_chart),
                  label: Text(S.roulette),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.monetization_on_outlined),
                  selectedIcon: Icon(Icons.monetization_on),
                  label: Text(S.coin),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.casino_outlined),
                  selectedIcon: Icon(Icons.casino),
                  label: Text(S.dice),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: Text(S.magicBall),
                ),
              ],
            ),
            VerticalDivider(width: 1, color: scheme.outlineVariant),
            Expanded(child: pages),
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(_titles[_index], key: ValueKey(_index)),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width < 760)
            IconButton(
              tooltip: S.settings,
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): _TriggerIntent(),
        },
        child: Actions(
          actions: {
            _TriggerIntent: CallbackAction<_TriggerIntent>(
              onInvoke: (_) {
                context.read<ToolShortcuts>().fire(_pageKeys[_index]);
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: BlobBackground(
              enabled: settings.blob,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TriggerIntent extends Intent {
  const _TriggerIntent();
}
