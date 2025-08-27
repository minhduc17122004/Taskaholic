import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;  // Alternative to title string
  final String? subtitle;
  final bool showBackButton;
  final Widget? leadingIcon;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.showBackButton = true,
    this.leadingIcon,
    this.actions,
  }) : assert(title != null || titleWidget != null, 
             'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 0,
      leading: leadingIcon ?? 
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: titleWidget ?? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title!,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// SearchableAppBar - AppBar với search functionality
class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String searchHint;
  final Function(String) onSearchChanged;
  final List<Widget>? actions;
  final TextEditingController? searchController;

  const SearchableAppBar({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    this.actions,
    this.searchController,
  });

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      widget.onSearchChanged('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 0,
      title: _isSearching 
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: widget.onSearchChanged,
              style: const TextStyle(color: AppColors.textOnPrimary),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      actions: [
        if (_isSearching)
          IconButton(
            onPressed: _stopSearch,
            icon: const Icon(Icons.close, color: AppColors.textOnPrimary),
          )
        else ...[
          IconButton(
            onPressed: _startSearch,
            icon: const Icon(Icons.search, color: AppColors.textOnPrimary),
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
      ],
    );
  }
}
