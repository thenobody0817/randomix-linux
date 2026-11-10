/// Accent palette, taken from the upstream `colors.xml` seeds.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../strings.dart';

enum Accent {
  system('system', S.systemAccent, null),
  blue('blue', S.blue, Color(0xFF4285F4)),
  aqua('aqua', S.aqua, Color(0xFF5ABF95)),
  green('green', S.green, Color(0xFF3DDC84)),
  orange('orange', S.orange, Color(0xFFFF7522)),
  yellow('yellow', S.yellow, Color(0xFFF4B400)),
  teal('teal', S.teal, Color(0xFF008080)),
  violet('violet', S.violet, Color(0xFFAB47BC)),
  pink('pink', S.pink, Color(0xFFFF66CC)),
  lightBlue('lightBlue', S.lightBlue, Color(0xFF29B6F6)),
  red('red', S.red, Color(0xFFFF5252)),
  lime('lime', S.lime, Color(0xFFC5DE00)),
  crimson('crimson', S.crimson, Color(0xFFDC143C));

  const Accent(this.id, this.label, this.seed);

  final String id;
  final String label;

  /// `null` for [Accent.system], resolved at runtime from the desktop.
  final Color? seed;

  /// The colour to show in the picker when the seed is not known yet.
  Color get swatch => seed ?? const Color(0xFF4285F4);

  static Accent fromId(String? id) =>
      Accent.values.firstWhere((a) => a.id == id, orElse: () => Accent.blue);
}

/// Reads the GNOME accent colour, if the desktop exposes one.
///
/// GNOME 47+ has `org.gnome.desktop.interface accent-color`; older desktops
/// don't, in which case blue is used.
class SystemAccent {
  const SystemAccent._();

  static const _colors = <String, Color>{
    'blue': Color(0xFF3584E4),
    'teal': Color(0xFF2190A4),
    'green': Color(0xFF3A944A),
    'yellow': Color(0xFFC88800),
    'orange': Color(0xFFED5B00),
    'red': Color(0xFFE62D42),
    'pink': Color(0xFFD56199),
    'purple': Color(0xFF9141AC),
    'slate': Color(0xFF6F8396),
  };

  static Future<Color?> detect() async {
    try {
      final result = await Process.run('gsettings', [
        'get',
        'org.gnome.desktop.interface',
        'accent-color',
      ]);
      if (result.exitCode != 0) return null;
      final name = result.stdout.toString().trim().replaceAll("'", '');
      return _colors[name];
    } catch (_) {
      return null;
    }
  }
}
