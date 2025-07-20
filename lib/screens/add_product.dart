import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_catalog_app/widget/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:product_catalog_app/providers/product_provider.dart';
import 'package:product_catalog_app/utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;
  final int initialTabIndex;
  final void Function(int)? onTabSelected;
  const AddProductScreen({
    super.key,
    this.productToEdit,
    this.initialTabIndex = 0,
    this.onTabSelected,
  });
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  String?
      _pickedImagePath; // Temporary path from image_picker for newly selected image
  String?
      _currentProductImagePath; // Permanent path for existing product's image
  DateTime? _createdAt; // To store and pass original creation date for edits
  bool _isFavorite = false; // To store and pass favorite status for edits

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.productToEdit != null) {
      _titleController.text = widget.productToEdit!.title;
      _descriptionController.text = widget.productToEdit!.description;
      _priceController.text = widget.productToEdit!.price.toStringAsFixed(2);
      _categoryController.text = widget.productToEdit!.category;
      _currentProductImagePath = widget.productToEdit!.image;
      _createdAt = widget.productToEdit!.createdAt;
      _isFavorite = widget.productToEdit!.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.productToEdit == null && _pickedImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select an image for the product.')),
        );
        return;
      }

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      final String title = _titleController.text.trim();
      final String description = _descriptionController.text.trim();
      final double price = double.parse(_priceController.text.trim());
      final String category = _categoryController.text.trim();

      try {
        if (widget.productToEdit == null) {
          await productProvider.addCustomProduct(
            title: title,
            description: description,
            price: price,
            category: category,
            imagePath: _pickedImagePath!,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully!')),
            );
          }
        } else {
          await productProvider.updateCustomProduct(
            id: widget.productToEdit!.id,
            title: title,
            description: description,
            price: price,
            category: category,
            newImagePath: _pickedImagePath,
            currentImagePath: _currentProductImagePath!,
            createdAt: _createdAt!,
            isFavorite: _isFavorite,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully!')),
            );
          }
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Operation failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final displayImageFile = _pickedImagePath != null
        ? File(_pickedImagePath!)
        : (isEditing &&
                _currentProductImagePath != null &&
                File(_currentProductImagePath!).existsSync()
            ? File(_currentProductImagePath!)
            : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPaddingM),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildImagePickerSection(context, isEditing, displayImageFile),
              const SizedBox(height: kPaddingL),
              _buildTextField(
                controller: _titleController,
                labelText: 'Product Title',
                icon: Icons.title,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: kPaddingM),
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: kPaddingM),
              _buildTextField(
                controller: _priceController,
                labelText: 'Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a price';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: kPaddingM),
              _buildTextField(
                controller: _categoryController,
                labelText: 'Category',
                icon: Icons.category,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a category'
                    : null,
              ),
              const SizedBox(height: kPaddingL),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Product' : 'Add Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: kPaddingS),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius)),
                  textStyle: kTitleTextStyle.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.initialTabIndex,
        onItemSelected: (index) {
          if (widget.onTabSelected != null) {
            widget.onTabSelected!(index); // tell parent to update tab
          }
          Navigator.pop(context); // go back to HomeScreen
        },
      ),
    );
  }

  Widget _buildImagePickerSection(
      BuildContext context, bool isEditing, File? displayImageFile) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImageSourceActionSheet(context),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: displayImageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  child: Image.file(
                    displayImageFile,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image,
                          size: 50, color: Colors.grey[600]);
                    },
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                    const SizedBox(height: kPaddingS),
                    Text(
                      isEditing ? 'Change Image' : 'Add Image',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
