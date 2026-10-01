import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/responsive.dart';

class AddRecipeScreen extends StatefulWidget {
  final VoidCallback onDone;
  const AddRecipeScreen({super.key, required this.onDone});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _emoji = TextEditingController(text: '🍽️');
  final _prepTime = TextEditingController(text: '20');
  final _calories = TextEditingController(text: '350');
  final _servings = TextEditingController(text: '2');

  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<Map<String, TextEditingController>> _ingredients = [_newIngredientRow()];
  final List<TextEditingController> _steps = [TextEditingController()];

  static Map<String, TextEditingController> _newIngredientRow() => {
        'name': TextEditingController(),
        'amount': TextEditingController(),
        'unit': TextEditingController(text: 'g'),
      };

  @override
  void dispose() {
    for (final c in [_title, _emoji, _prepTime, _calories, _servings]) {
      c.dispose();
    }
    for (final row in _ingredients) {
      for (final c in row.values) {
        c.dispose();
      }
    }
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  void _removeIngredient(int i) {
    if (_ingredients.length < 2) return;
    setState(() => _ingredients.removeAt(i).values.forEach((c) => c.dispose()));
  }

  void _removeStep(int i) {
    if (_steps.length < 2) return;
    setState(() => _steps.removeAt(i).dispose());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final cats = context.read<CategoryProvider>().categories;
      final category = _selectedCategory ?? (cats.isNotEmpty ? cats.first : 'Healthy');

      final ingredients = <Ingredient>[
        for (final row in _ingredients)
          if (row['name']!.text.trim().isNotEmpty)
            Ingredient(
              row['name']!.text.trim(),
              double.tryParse(row['amount']!.text.trim()) ?? 1.0,
              row['unit']!.text.trim(),
            ),
      ];
      final steps = [
        for (final c in _steps)
          if (c.text.trim().isNotEmpty) c.text.trim(),
      ];

      final recipe = Recipe(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        emoji: _emoji.text.trim().isEmpty ? '🍽️' : _emoji.text.trim(),
        category: category,
        time: int.tryParse(_prepTime.text.trim()) ?? 20,
        calories: int.tryParse(_calories.text.trim()) ?? 350,
        servings: (int.tryParse(_servings.text.trim()) ?? 2).clamp(1, 99),
        ingredients: ingredients.isNotEmpty ? ingredients : [const Ingredient('Love & Spices', 1, 'pinch')],
        steps: steps.isNotEmpty ? steps : ['Prepare ingredients and cook with passion.'],
      );

      await context.read<RecipeProvider>().add(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe "${recipe.title}" published successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish recipe: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
      );

  Widget _labeled(String label, Widget field) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label(label), field]);

  Widget _numberField(TextEditingController c, String hint) =>
      TextFormField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint));

  Widget _sectionHeader(String title, String buttonText, VoidCallback onAdd) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _label(title),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add_rounded, size: 18, color: primary),
          label: Text(buttonText, style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final primary = Theme.of(context).colorScheme.primary;
    final desktop = isDesktop(context);

    final titleField = _labeled(
      'Recipe Title *',
      TextFormField(
        controller: _title,
        decoration: const InputDecoration(hintText: 'e.g. Creamy Tuscan Garlic Chicken'),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
      ),
    );

    final categoryField = _labeled(
      'Category *',
      DropdownButtonFormField<String>(
        value: _selectedCategory ?? (categories.isNotEmpty ? categories.first : null),
        items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
        onChanged: (v) => setState(() => _selectedCategory = v),
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(desktop ? 32 : 20),
            children: [
              Text('Add New Recipe',
                  style: GoogleFonts.plusJakartaSans(fontSize: desktop ? 24 : 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),

              if (desktop)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 6, child: titleField),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: categoryField),
                ])
              else ...[
                titleField,
                const SizedBox(height: 18),
                categoryField,
              ],
              const SizedBox(height: 18),

              _labeled('Emoji', SizedBox(width: 120, child: TextFormField(controller: _emoji))),
              const SizedBox(height: 18),

              Row(children: [
                Expanded(child: _labeled('Prep Time (min)', _numberField(_prepTime, '25'))),
                const SizedBox(width: 14),
                Expanded(child: _labeled('Calories (kcal)', _numberField(_calories, '450'))),
                const SizedBox(width: 14),
                Expanded(child: _labeled('Base Servings', _numberField(_servings, '2'))),
              ]),
              const SizedBox(height: 28),

              _sectionHeader('Ingredients', 'Add Ingredient',
                  () => setState(() => _ingredients.add(_newIngredientRow()))),
              for (var i = 0; i < _ingredients.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _ingredients[i]['name'],
                        decoration: const InputDecoration(hintText: 'Item name (e.g. Cheese)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _ingredients[i]['amount'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Qty'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _ingredients[i]['unit'],
                        decoration: const InputDecoration(hintText: 'Unit'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeIngredient(i),
                    ),
                  ]),
                ),
              const SizedBox(height: 18),

              _sectionHeader('Step-by-Step Instructions', 'Add Step',
                  () => setState(() => _steps.add(TextEditingController()))),
              for (var i = 0; i < _steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 14),
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Text('${i + 1}',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _steps[i],
                        maxLines: 2,
                        decoration: InputDecoration(hintText: 'Describe step ${i + 1}...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeStep(i),
                    ),
                  ]),
                ),
              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text('Publish Recipe',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
