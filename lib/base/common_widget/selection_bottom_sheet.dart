import 'package:flutter/material.dart';
import 'package:learn_english_app/resources/app_resources.dart';

class SelectionBottomSheetScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final ValueChanged<String>? onSearchChanged;
  final Widget child;
  final String searchHint;

  const SelectionBottomSheetScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.onSearchChanged,
    required this.child,
    this.searchHint = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: AppColor.appPrimaryColor),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSearchChanged != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffDEE1E7)),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: onSearchChanged,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                        hintText: searchHint,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const Divider(height: 1),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectionBottomSheetTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectionBottomSheetTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected ? AppColor.appPrimaryColor : Colors.black87,
          fontSize: 14,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              )
              : null,
      trailing:
          selected
              ? Icon(
                Icons.check_circle_rounded,
                color: AppColor.appPrimaryColor,
                size: 20,
              )
              : null,
    );
  }
}

class SelectionBottomSheetEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const SelectionBottomSheetEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.search_off_rounded,
              size: 52,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
