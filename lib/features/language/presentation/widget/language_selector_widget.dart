import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_english_app/base/base.dart';
import 'package:learn_english_app/features/language/domain/domain.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_bloc.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_event.dart';
import 'package:learn_english_app/features/language/presentation/bloc/language_state.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String screenId;

  const LanguageSelectorWidget({super.key, required this.screenId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final currentLanguage = state.currentLanguage;
        final supportedLanguages = state.supportedLanguages ?? [];

        if (supportedLanguages.isEmpty) {
          return const SizedBox.shrink();
        }

        // If more than 2 languages, show as a simple switch with current language
        if (supportedLanguages.length > 2) {
          return _buildMultiLanguageToggle(context, currentLanguage, supportedLanguages, state.progress == true);
        }

        // For 2 languages, show as a toggle switcher
        return _buildToggleSwitcher(context, currentLanguage, supportedLanguages, state.progress == true);
      },
    );
  }

  Widget _buildToggleSwitcher(
    BuildContext context,
    LanguageModel? currentLanguage,
    List<LanguageModel> languages,
    bool isLoading,
  ) {
    final title = {"ar": languages[0], "en": languages[1]};
    final switcherLanguage = title[currentLanguage?.code ?? ""];

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16,end: 16,top: 10,bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.appPrimaryColor, width: 1.2),
      ),
      child:  Row(
        children: [
          Icon(Icons.language, color: AppColor.appPrimaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.localization.language,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              if (switcherLanguage != null && currentLanguage?.code != switcherLanguage.code) {
                context.read<LanguageBloc>().add(
                  ChangeLanguageEvent(languageCode: switcherLanguage.code, screenId: screenId),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(switcherLanguage?.nativeName ?? "",style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                   color: AppColor.appPrimaryColor,
                ),),
                8.pw,
                Icon(Icons.arrow_forward_ios_rounded)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLanguageToggle(
    BuildContext context,
    LanguageModel? currentLanguage,
    List<LanguageModel> languages,
    bool isLoading,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.appPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.language, color: AppColor.appPrimaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.localization.language,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                languages.map((language) {
                  final isSelected = currentLanguage?.code == language.code;
                  return InkWell(
                    onTap:
                        isLoading
                            ? null
                            : () {
                              if (!isSelected) {
                                context.read<LanguageBloc>().add(
                                  ChangeLanguageEvent(languageCode: language.code, screenId: screenId),
                                );
                              }
                            },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColor.appPrimaryColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        language.nativeName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LanguageToggleSwitcher extends StatelessWidget {
  final List<LanguageModel> languages;
  final int selectedIndex;
  final bool isLoading;
  final ValueChanged<int> onLanguageSelected;

  const _LanguageToggleSwitcher({
    required this.languages,
    required this.selectedIndex,
    required this.isLoading,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(25)),
      child: Stack(
        children: [
          // Animated indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: selectedIndex == 0 ? 2 : null,
            right: selectedIndex == 1 ? 2 : null,
            top: 2,
            bottom: 2,
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.warning,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.warning.withAlpha(0.3.toAlpha()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Language options
          Row(
            children: List.generate(
              languages.length,
              (index) => Expanded(
                child: TouchableOpacity(
                  onTap: isLoading ? null : () => onLanguageSelected(index),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(23)),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: context.textTheme.titleMedium!.copyWith(
                        color: selectedIndex == index ? Colors.black : Colors.black,
                        fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                      child: Text(languages[index].nativeName),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
