import 'package:flutter/material.dart';
import 'package:product_catalog_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _tempSelectedCategory;
  RangeValues? _tempPriceRange;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _tempSelectedCategory = productProvider.selectedCategory;
    _tempPriceRange = productProvider.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPaddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Products',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: kPaddingL,thickness: 1.5,),

          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kPaddingS),
          Wrap(
            spacing: kPaddingS,
            runSpacing: kPaddingS,
            children: [
              // "All" category option
              ChoiceChip(
                label: const Text('All'),
                selected: _tempSelectedCategory == null || _tempSelectedCategory!.isEmpty,
                onSelected: (selected) {
                  setState(() {
                    _tempSelectedCategory = selected ? null : _tempSelectedCategory;
                  });
                },
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                 backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                labelStyle: _tempSelectedCategory == null || _tempSelectedCategory!.isEmpty
                    ? Theme.of(context).chipTheme.secondaryLabelStyle 
                    : Theme.of(context).chipTheme.labelStyle,
                shape: Theme.of(context).chipTheme.shape,
              ),
              ...productProvider.availableCategories.map((category) {
                 return ChoiceChip(
                  label: Text(category),
                  selected: _tempSelectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _tempSelectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: Theme.of(context).chipTheme.selectedColor,
                  backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                  labelStyle: _tempSelectedCategory == category
                      ? Theme.of(context).chipTheme.secondaryLabelStyle
                      : Theme.of(context).chipTheme.labelStyle,
                  shape: Theme.of(context).chipTheme.shape,
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: kPaddingL),
           Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${_tempPriceRange!.start.toStringAsFixed(0)} - \$${_tempPriceRange!.end.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          RangeSlider(
            values: _tempPriceRange!,
            min: 0,
            max: productProvider.maxPrice,
            divisions: (productProvider.maxPrice / 10).round().clamp(1, 100), // Ensure at least 1 division, max 100
            labels: RangeLabels(
              _tempPriceRange!.start.toStringAsFixed(0),
              _tempPriceRange!.end.toStringAsFixed(0),
            ),
            onChanged: (newRange) {
              setState(() {
                _tempPriceRange = newRange;
              });
            },
          ),
          const SizedBox(height: kPaddingL),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    productProvider.resetFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    padding: const EdgeInsets.symmetric(vertical: kPaddingS),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: kPaddingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    productProvider.setSelectedCategory(_tempSelectedCategory);
                    productProvider.setPriceRange(_tempPriceRange!);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
                    padding: const EdgeInsets.symmetric(vertical: kPaddingS),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
