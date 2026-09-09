import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onExploreTap;

  const FavoritesScreen({super.key, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favorites = recipeProvider.favoriteRecipes;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Recipes (${favorites.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.desktopContentMaxWidth),
          child: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No favorites yet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap the heart icon on any recipe to save your favorite dishes here for quick access.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: onExploreTap,
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('Explore Recipes'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 32,
                    16,
                    isMobile ? 20 : 32,
                    32,
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 320 : 360,
                      mainAxisSpacing: isMobile ? 18 : 24,
                      crossAxisSpacing: isMobile ? 18 : 24,
                      childAspectRatio: isMobile ? 0.85 : 0.88,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final recipe = favorites[index];
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
                  ),
                ),
        ),
      ),
    );
  }
}
