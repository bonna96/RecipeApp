import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    final recipes = recipeProvider.getFilteredRecipes(categoryProvider.selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.desktopContentMaxWidth),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar & Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 20 : 32,
                      isMobile ? 20 : 32,
                      isMobile ? 20 : 32,
                      12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Foodie! 👋',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'What to cook today?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        // On mobile, show theme toggle here (on desktop it's in the sidebar rail)
                        if (isMobile)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: themeProvider.toggleTheme,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                  size: 20,
                                  color: themeProvider.isDarkMode ? Colors.amber : Colors.indigo,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: 12,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: recipeProvider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search recipes by name or ingredients (e.g. paneer, salmon, pasta)...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                          suffixIcon: recipeProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                  onPressed: recipeProvider.clearSearch,
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          final isSelected = category.name.toLowerCase() ==
                              categoryProvider.selectedCategory.toLowerCase();

                          return CategoryChip(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              categoryProvider.selectCategory(category.name);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Section Title & Counter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 20 : 32,
                      24,
                      isMobile ? 20 : 32,
                      16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoryProvider.selectedCategory == 'All'
                              ? 'Popular Recipes'
                              : '${categoryProvider.selectedCategory} Recipes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${recipes.length} available',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Responsive Recipe Grid or Empty State
                recipes.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🍳', style: TextStyle(fontSize: 54)),
                              const SizedBox(height: 16),
                              Text(
                                'No recipes found',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try clearing your search or switching to another category.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 20 : 32,
                          0,
                          isMobile ? 20 : 32,
                          40,
                        ),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: isMobile ? 320 : 360,
                            mainAxisSpacing: isMobile ? 18 : 24,
                            crossAxisSpacing: isMobile ? 18 : 24,
                            childAspectRatio: isMobile ? 0.85 : 0.88,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final recipe = recipes[index];
                              return RecipeCard(
                                recipe: recipe,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                },
                                onFavoriteToggle: () {
                                  recipeProvider.toggleFavorite(recipe.id);
                                },
                              );
                            },
                            childCount: recipes.length,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
