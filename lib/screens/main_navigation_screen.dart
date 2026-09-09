import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'add_recipe_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDesktopOrTablet = !context.isMobile;

    final pages = [
      const HomeScreen(),
      CategoriesScreen(
        onCategorySelected: (cat) => _switchTab(0),
      ),
      FavoritesScreen(
        onExploreTap: () => _switchTab(0),
      ),
      AddRecipeScreen(
        onRecipeAdded: () => _switchTab(0),
      ),
    ];

    if (isDesktopOrTablet) {
      // Desktop & Web Layout: Left-Side Navigation Rail
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand Logo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('🍳', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RecipeApp',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Culinary Suite',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Navigation Links
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildDesktopNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Explore', isDark),
                        const SizedBox(height: 6),
                        _buildDesktopNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories', isDark),
                        const SizedBox(height: 6),
                        _buildDesktopNavItem(2, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorites', isDark),
                        const SizedBox(height: 6),
                        _buildDesktopNavItem(3, Icons.add_box_rounded, Icons.add_box_outlined, 'Add Recipe', isDark),
                      ],
                    ),
                  ),

                  // Theme Toggle & Footer
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                size: 18,
                                color: themeProvider.isDarkMode ? Colors.amber : AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: themeProvider.isDarkMode,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout: Bottom Navigation Bar
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMobileNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', isDark),
                _buildMobileNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories', isDark),
                _buildMobileNavItem(2, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorites', isDark),
                _buildMobileNavItem(3, Icons.add_box_rounded, Icons.add_box_outlined, 'Add Recipe', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    return _DesktopNavButton(
      index: index,
      isSelected: _currentIndex == index,
      activeIcon: activeIcon,
      inactiveIcon: inactiveIcon,
      label: label,
      isDark: isDark,
      onTap: () => _switchTab(index),
    );
  }

  Widget _buildMobileNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _switchTab(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white60 : Colors.black45),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopNavButton extends StatefulWidget {
  final int index;
  final bool isSelected;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _DesktopNavButton({
    required this.index,
    required this.isSelected,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DesktopNavButton> createState() => _DesktopNavButtonState();
}

class _DesktopNavButtonState extends State<_DesktopNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryColor
                : (_isHovered
                    ? (widget.isDark
                        ? Colors.white.withOpacity(0.07)
                        : AppTheme.primaryColor.withOpacity(0.08))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                transform: Matrix4.identity()
                  ..translate(_isHovered && !widget.isSelected ? 3.0 : 0.0, 0.0),
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.inactiveIcon,
                  size: 20,
                  color: widget.isSelected
                      ? Colors.white
                      : (_isHovered
                          ? AppTheme.primaryColor
                          : (widget.isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isSelected
                      ? Colors.white
                      : (_isHovered
                          ? (widget.isDark ? Colors.white : AppTheme.primaryColor)
                          : (widget.isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
