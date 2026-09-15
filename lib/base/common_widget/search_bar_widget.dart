
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:learn_english_app/base/common_widget/touchable_opacity.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class SearchBarWidget extends StatefulWidget {
  final String? hintText;
  final void Function(String) onSearch;
  final void Function()? onClear;
  final bool enable;
  final IconData icon;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText,
    this.onClear,
    this.enable = true,
    this.icon = Iconsax.search_normal_1_outline,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool isClear = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;

      if (hasText != isClear) {
        setState(() {
          isClear = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        // color: AppColor.appBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        textAlignVertical: TextAlignVertical.center,
        onTap: () {
          _searchFocus.requestFocus();
        },
        onSubmitted: (value) {
          widget.onSearch(value);
          _searchFocus.unfocus();
        },
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.name,
        onTapOutside: (_) {
          _searchFocus.unfocus();
        },
        enabled: widget.enable,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Icon(widget.icon, size: 20, color: Colors.black54),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: isClear
              ? TouchableOpacity(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(color: AppColor.appBackground, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.close, size: 21),
                  ),
                  onTap: () {
                    _searchFocus.unfocus();
                    _searchController.clear();
                    widget.onClear?.call();
                  },
                )
              : null,
          contentPadding: const EdgeInsetsDirectional.only(start: 0, end: 16),
          hintText: widget.hintText,
          hintStyle: context.textTheme.bodyLarge?.copyWith(
            color: AppColor.appTextSecondaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),

          constraints: const BoxConstraints(maxHeight: 48, maxWidth: double.infinity),
          isDense: true,
        ),
      ),
    );
  }
}
