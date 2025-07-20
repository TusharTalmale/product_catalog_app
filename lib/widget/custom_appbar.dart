import 'package:flutter/material.dart';
import 'package:product_catalog_app/utils/view_mode.dart';
import 'package:product_catalog_app/widget/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final String title;

  const CustomHomeAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final bool filtersActive = productProvider.selectedCategory != null ||
        productProvider.priceRange.start > 0 ||
        productProvider.priceRange.end < productProvider.maxPrice ||
        productProvider.showFavoritesOnly;

    return AppBar(
      title:  Text(title), 
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight - 10), 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPaddingM, vertical: kPaddingS),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged();
                            },
                          )
                        : null,
                        
                    border: Theme.of(context).inputDecorationTheme.border,
                    enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                    focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                    filled: Theme.of(context).inputDecorationTheme.filled,
                    fillColor: Colors.white.withOpacity(0.2), 
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                ),
              ),
              const SizedBox(width: kPaddingS),
              // Filter Icon
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: filtersActive ? Theme.of(context).colorScheme.secondary : Colors.white,
                  size: 20,
                ),
                tooltip: 'Filter Products',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const FilterBottomSheet(),
                  );
                },
              ),
              // Theme Toggle
              IconButton(
                icon: Icon(
                  productProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: productProvider.themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  productProvider.toggleTheme();
                },
              ),
              // View Mode Toggle (Grid/List)
              IconButton(
                icon: Icon(
                  productProvider.viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_on,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: productProvider.viewMode == ViewMode.grid ? 'Switch to List View' : 'Switch to Grid View',
                onPressed: () {
                  productProvider.setViewMode(
                    productProvider.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.8); 
}
