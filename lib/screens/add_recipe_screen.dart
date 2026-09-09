import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AddRecipeScreen extends StatefulWidget {
  final VoidCallback onRecipeAdded;

  const AddRecipeScreen({super.key, required this.onRecipeAdded});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '20');
  final _caloriesController = TextEditingController(text: '350');
  final _servingsController = TextEditingController(text: '2');

  String? _selectedCategory;

  final List<Map<String, TextEditingController>> _ingredientControllers = [
    {
      'name': TextEditingController(),
      'amount': TextEditingController(),
      'unit': TextEditingController(text: 'g'),
    }
  ];

  final List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final categories = Provider.of<CategoryProvider>(context, listen: false).categories;
    final nonAll = categories.where((c) => c.name.toLowerCase() != 'all').toList();
    if (nonAll.isNotEmpty) {
      _selectedCategory = nonAll.first.name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _caloriesController.dispose();
    _servingsController.dispose();

    for (var row in _ingredientControllers) {
      row['name']?.dispose();
      row['amount']?.dispose();
      row['unit']?.dispose();
    }
    for (var c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
        'unit': TextEditingController(text: 'g'),
      });
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        final row = _ingredientControllers.removeAt(index);
        row['name']?.dispose();
        row['amount']?.dispose();
        row['unit']?.dispose();
      });
    }
  }

  void _addInstructionRow() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionRow(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers.removeAt(index).dispose();
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final ingredients = <Ingredient>[];
      for (var row in _ingredientControllers) {
        final name = row['name']!.text.trim();
        final amount = double.tryParse(row['amount']!.text.trim()) ?? 1.0;
        final unit = row['unit']!.text.trim();
        if (name.isNotEmpty) {
          ingredients.add(Ingredient(name: name, amount: amount, unit: unit));
        }
      }

      final instructions = <String>[];
      for (var c in _instructionControllers) {
        if (c.text.trim().isNotEmpty) {
          instructions.add(c.text.trim());
        }
      }

      final defaultImage = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1000&q=80';

      final newRecipe = Recipe(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory ?? 'Main Course',
        imageUrl: defaultImage,
        prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? 20,
        calories: int.tryParse(_caloriesController.text.trim()) ?? 350,
        baseServings: int.tryParse(_servingsController.text.trim()) ?? 2,
        rating: 5.0,
        reviewCount: 1,
        ingredients: ingredients.isNotEmpty
            ? ingredients
            : [const Ingredient(name: 'Love & Spices', amount: 1, unit: 'pinch')],
        instructions: instructions.isNotEmpty
            ? instructions
            : ['Prepare ingredients and cook with passion.'],
        isFavorite: false,
        createdAt: DateTime.now(),
      );

      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      await recipeProvider.addRecipe(newRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe "${newRecipe.title}" published successfully!'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onRecipeAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish recipe: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    final validCategories = categories.where((c) => c.name.toLowerCase() != 'all').toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Recipe',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              children: [
                if (!isMobile) ...[
                  // Desktop Row: Title and Category side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Recipe Title *', isDark),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(hintText: 'e.g. Creamy Tuscan Garlic Chicken'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Category *', isDark),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory ?? (validCategories.isNotEmpty ? validCategories.first.name : null),
                              decoration: const InputDecoration(),
                              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                              items: validCategories.map((c) {
                                return DropdownMenuItem(
                                  value: c.name,
                                  child: Row(
                                    children: [
                                      Text(c.icon),
                                      const SizedBox(width: 8),
                                      Text(c.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Mobile Column
                  _buildLabel('Recipe Title *', isDark),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'e.g. Creamy Tuscan Garlic Chicken'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Category *', isDark),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory ?? (validCategories.isNotEmpty ? validCategories.first.name : null),
                    decoration: const InputDecoration(),
                    dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                    items: validCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.name,
                        child: Row(
                          children: [
                            Text(c.icon),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ],

                const SizedBox(height: 18),

                // Image URL
                _buildLabel('Image URL (Web link or Unsplash)', isDark),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://images.unsplash.com/... (optional)',
                  ),
                ),
                const SizedBox(height: 18),

                // Macros Row: Prep Time, Calories, Servings
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Prep Time (min)', isDark),
                          TextFormField(
                            controller: _prepTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '25'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Calories (kcal)', isDark),
                          TextFormField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '450'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Base Servings', isDark),
                          TextFormField(
                            controller: _servingsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '2'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Dynamic Ingredients Builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Ingredients', isDark),
                    TextButton.icon(
                      onPressed: _addIngredientRow,
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryColor),
                      label: Text(
                        'Add Ingredient',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredientControllers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final row = _ingredientControllers[idx];
                    return Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: row['name'],
                            decoration: const InputDecoration(
                              hintText: 'Item name (e.g. Cheese)',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: row['amount'],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Qty',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: row['unit'],
                            decoration: const InputDecoration(
                              hintText: 'Unit',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeIngredientRow(idx),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Dynamic Instructions Builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Step-by-Step Instructions', isDark),
                    TextButton.icon(
                      onPressed: _addInstructionRow,
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryColor),
                      label: Text(
                        'Add Step',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _instructionControllers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 14),
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${idx + 1}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _instructionControllers[idx],
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Describe step ${idx + 1}...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeInstructionRow(idx),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRecipe,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_rounded),
                              const SizedBox(width: 8),
                              Text(
                                'Publish Recipe',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
        ),
      ),
    );
  }
}
