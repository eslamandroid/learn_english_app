import 'package:flutter/widgets.dart';

/// Drops and rebuilds the entire widget subtree below it by swapping a
/// [UniqueKey] on a [KeyedSubtree]. Every bloc, repo singleton instance, and
/// cached state inside the tree is recreated from scratch — including
/// constructor reads of `SharedPreferences`, which is exactly what we want
/// after the user changes their CEFR level.
///
/// Wrap the topmost app widget once:
///
///   runApp(const Phoenix(child: MyApp()));
///
/// Then trigger from anywhere with a [BuildContext]:
///
///   Phoenix.rebirth(context);
///
/// Note: this only rebuilds the Dart tree. Native singletons (Firebase,
/// audio sessions, etc.) and `get_it` singletons live outside the subtree
/// and survive — that's deliberate, we only want bloc/repo state reset.
class Phoenix extends StatefulWidget {
  final Widget child;

  const Phoenix({super.key, required this.child});

  static void rebirth(BuildContext context) {
    final state = context.findAncestorStateOfType<_PhoenixState>();
    state?._rebirth();
  }

  @override
  State<Phoenix> createState() => _PhoenixState();
}

class _PhoenixState extends State<Phoenix> {
  Key _key = UniqueKey();

  void _rebirth() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
