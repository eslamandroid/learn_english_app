import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../core/utils/content_language.dart';
import '../widgets/app_locale_row.dart';
import '../widgets/cefr_level_row.dart';
import '../widgets/settings_row.dart';
import '../widgets/value_with_stepper.dart';
import '../widgets/voice_accent_row.dart';
import '../widgets/voice_gender_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayanColors.background,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 60,
        title: Text(
          'Settings',
          style: BayanTypography.headlineMedium.copyWith(
            color: BayanColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20.spMin,
          ),
        ),
        actions: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BayanColors.inverseSurface,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: BayanColors.inverseOnSurface,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.containerPadding,
          AppConstants.spacingLg,
          AppConstants.containerPadding,
          AppConstants.spacingLg,
        ),
        children: [
          const _SectionLabel('ACCOUNT SETTINGS'),
          14.ph,
          _Card(
            children: [
              SettingsRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                subtitle: 'user.name@example.com',
                trailing: const _Chevron(),
                onTap: () {},
              ),
              const _RowDivider(),
              SettingsRow(
                icon: Icons.lock_outline_rounded,
                title: 'Password',
                trailing: const _Chevron(),
                onTap: () {},
              ),
              const _RowDivider(),
              SettingsRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Subscription',
                subtitle: 'Bayan Premium Active',
                subtitleColor: BayanColors.secondary,
                trailing: const _Chevron(),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),
          const _SectionLabel('LEARNING PREFERENCES'),
          _Card(
            children: [
              SettingsRow(
                icon: Icons.speed_rounded,
                title: 'Daily Goal',
                trailing: const ValueWithStepper(value: '20 mins'),
                onTap: () {},
              ),
              const _RowDivider(),
              const CefrLevelRow(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),
          const _SectionLabel('APP CUSTOMIZATION'),
          _Card(
            children: [
              SettingsRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: _darkMode,
                  activeThumbColor: BayanColors.primary,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ),
              const _RowDivider(),
              const VoiceAccentRow(),
              const _RowDivider(),
              const VoiceGenderRow(),
              const _RowDivider(),
              const _ShowArabicRow(),
              const _RowDivider(),
              const AppLocaleRow(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          _Card(
            children: [
              SettingsRow(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: BayanColors.onSurfaceVariant,
                ),
                onTap: () {},
              ),
              const _RowDivider(),
              SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: const _Chevron(),
                onTap: () {},
              ),
              const _RowDivider(),
              const _LogoutRow(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Center(
            child: Text(
              'Bayan English v2.4.0',
              style: BayanTypography.bodySmall.copyWith(
                color: BayanColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.spacingXs,
        bottom: AppConstants.spacingSm,
      ),
      child: Text(
        text,
        style: BayanTypography.labelMedium.copyWith(
          color: BayanColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 18.spMin,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BayanColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: AppConstants.spacingMd,
      endIndent: AppConstants.spacingMd,
      color: BayanColors.outlineVariant,
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right_rounded,
      color: BayanColors.onSurfaceVariant,
    );
  }
}

class _ShowArabicRow extends StatelessWidget {
  const _ShowArabicRow();

  @override
  Widget build(BuildContext context) {
    final l = context.localization;
    return ValueListenableBuilder<bool>(
      valueListenable: AppContentLanguage.instance.showArabic,
      builder: (context, visible, _) {
        return SettingsRow(
          icon: Icons.translate_rounded,
          title: l.showArabicTranslations,
          subtitle: l.showArabicTranslationsHint,
          trailing: Switch.adaptive(
            value: visible,
            activeThumbColor: BayanColors.primary,
            onChanged: AppContentLanguage.instance.setShowArabic,
          ),
        );
      },
    );
  }
}

class _LogoutRow extends StatelessWidget {
  const _LogoutRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingMd,
          ),
          child: Center(
            child: Text(
              'Log Out',
              style: BayanTypography.bodyLarge.copyWith(
                color: BayanColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
