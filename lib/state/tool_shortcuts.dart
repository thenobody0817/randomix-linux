/// Lets the shell's keyboard shortcuts trigger whichever tool is on screen.
library;

import 'package:flutter/foundation.dart';

class ToolShortcuts extends ChangeNotifier {
  final Map<String, VoidCallback> _handlers = <String, VoidCallback>{};

  void register(String key, VoidCallback handler) {
    _handlers[key] = handler;
  }

  void unregister(String key, VoidCallback handler) {
    if (_handlers[key] == handler) _handlers.remove(key);
  }

  void fire(String key) => _handlers[key]?.call();
}
