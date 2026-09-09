import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _prepTimeController;
  late TextEditingController _caloriesController;
  late TextEditingController _servingsController;

  String? _selectedCategory;
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  bool _isSaving = false;
  String _previewImageUrl = '';

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _titleController = TextEditingController(text: r.title);
    _imageUrlController = TextEditingController(text: r.imageUrl);
    _previewImageUrl = r.imageUrl;
    _prepTimeController = TextEditingController(text: r.prepTimeMinutes.toString());
    _caloriesController = TextEditingController(text: r.calories.toString());
    _servingsController = TextEditingController(text: r.baseServings.toString());
    _selectedCategory = r.category;

    _imageUrlController.addListener(() {
      if (mounted) {
        setState(() => _previewImageUrl = _imageUrlController.text.trim());
      }
    });

    // Populate existing ingredients
    if (r.ingredients.isNotEmpty) {
      for (var ing in r.ingredients) {
        _ingredientControllers.add({
          'name': TextEditingController(text: ing.name),
          'amount': TextEditingController(
            text: ing.amount == ing.amount.roundToDouble()
                ? ing.amount.toInt().toString()
                : ing.amount.toString(),
          ),
          'unit': TextEditingController(text: ing.unit),
        });
      }
    } else {
      _addIngredientRow();
    }

    // Populate existing instructions
    if (r.instructions.isNotEmpty) {
      for (var step in r.instructions) {
        _instructionControllers.add(TextEditingController(text: step));
      }
    } else {
      _addInstructionRow();
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

  Future<void> _confirmDeleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: Text('Are you sure you want to delete "${widget.recipe.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      await recipeProvider.deleteRecipe(widget.recipe.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe "${widget.recipe.title}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Pop back to home / list
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedIngredients = <Ingredient>[];
      for (var row in _ingredientControllers) {
        final name = row['name']!.text.trim();
        final amount = double.tryParse(row['amount']!.text.trim()) ?? 1.0;
        final unit = row['unit']!.text.trim();
        if (name.isNotEmpty) {
          updatedIngredients.add(Ingredient(name: name, amount: amount, unit: unit));
        }
      }

      final updatedInstructions = <String>[];
      for (var c in _instructionControllers) {
        if (c.text.trim().isNotEmpty) {
          updatedInstructions.add(c.text.trim());
        }
      }

      final updatedRecipe = widget.recipe.copyWith(
        title: _titleController.text.trim(),
        category: _selectedCategory ?? widget.recipe.category,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : widget.recipe.imageUrl,
        prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? widget.recipe.prepTimeMinutes,
        calories: int.tryParse(_caloriesController.text.trim()) ?? widget.recipe.calories,
        baseServings: int.tryParse(_servingsController.text.trim()) ?? widget.recipe.baseServings,
        ingredients: updatedIngredients.isNotEmpty ? updatedIngredients : widget.recipe.ingredients,
        instructions: updatedInstructions.isNotEmpty ? updatedInstructions : widget.recipe.instructions,
      );

      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      await recipeProvider.updateRecipe(updatedRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe "${updatedRecipe.title}" updated successfully!'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating recipe: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          'Edit Recipe',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Delete Recipe',
            onPressed: _confirmDeleteRecipe,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              children: [
                // Live Image Preview & Editing Box
                _buildLabel('Recipe Photo & Live Preview', isDark),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _previewImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _previewImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Invalid Image URL', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          hintText: 'Paste new image URL (e.g. Unsplash)...',
                          prefixIcon: Icon(Icons.link_rounded, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Category Row
                if (!isMobile) ...[
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
                              decoration: const InputDecoration(hintText: 'Recipe Title'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Category *', isDark),
                            DropdownButtonFormField<String>(
                              value: validCategories.any((c) => c.name == _selectedCategory)
                                  ? _selectedCategory
                                  : (validCategories.isNotEmpty ? validCategories.first.name : null),
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
                  _buildLabel('Recipe Title *', isDark),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Recipe Title'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Category *', isDark),
                  DropdownButtonFormField<String>(
                    value: validCategories.any((c) => c.name == _selectedCategory)
                        ? _selectedCategory
                        : (validCategories.isNotEmpty ? validCategories.first.name : null),
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

                const SizedBox(height: 20),

                // Macro Stats (Prep Time, Calories, Base Servings)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Prep (min)', isDark),
                          TextFormField(
                            controller: _prepTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '25'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Energy (kcal)', isDark),
                          TextFormField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '420'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Servings', isDark),
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

                // Dynamic Ingredients Editor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Edit Ingredients', isDark),
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
                              hintText: 'Ingredient (e.g. Paneer)',
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
                              hintText: 'Amount',
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

                // Dynamic Instructions Editor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Edit Step-by-Step Instructions', isDark),
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
                              hintText: 'Step ${idx + 1} instructions...',
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
                const SizedBox(height: 36),

                // Save Changes Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded),
                              const SizedBox(width: 8),
                              Text(
                                'Save Recipe Changes',
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
