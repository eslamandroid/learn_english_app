import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/extensions/context_ext.dart';

import '../../../../core/theme/bayan_colors.dart';
import '../widgets/main_bottom_nav.dart';

/// Top-level shell that hosts the five primary destinations
/// (Home / Learn / Talk / Words / Profile). Built around go_router's
/// `StatefulShellRoute.indexedStack` — each branch maintains its own
/// navigator stack so switching tabs preserves nested-route state.
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainShellScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    final items = <MainBottomNavItem>[
      MainBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l.homeTab,
      ),
      MainBottomNavItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
        label: l.learnTab,
      ),
      MainBottomNavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: l.talkTab,
      ),
      MainBottomNavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: l.wordsTab,
      ),
      MainBottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: l.profileTab,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: BayanColors.background,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BayanColors.background,
        body: shell,
        bottomNavigationBar: MainBottomNav(
          items: items,
          currentIndex: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
    );
  }
}
