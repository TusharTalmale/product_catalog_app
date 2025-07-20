import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemSelected,
      // Styling now primarily comes from Theme.of(context).bottomNavigationBarTheme
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed, 
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'All Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
          tooltip: 'Favorite Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Add Item',
          tooltip: 'Add New Product',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'My Items',
          tooltip: 'My Custom Products',
        ),
      ],
    );
  }
}
