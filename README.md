# 🍳 Complete Flutter Recipe App (Mobile, Windows & Web)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platforms-Mobile%20|%20Windows%20|%20Web-4285F4?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/State_Management-Provider-FF6F00?style=for-the-badge" alt="Provider" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

A feature-complete, modern culinary **Recipe Application** built with **Flutter**, **Firebase Cloud Firestore**, and **Provider** state management. Designed with a **responsive, multi-platform architecture** that adapts gracefully between **iOS, Android, Windows Desktop, and Web browsers**.

---

## 📸 Highlights & Responsive Multi-Platform Features

- 📱 **Mobile UX**: Ergonomic one-thumb bottom navigation, touch-optimized sliver headers, and fast horizontal category pills.
- 💻 **Desktop & Web UX**: 
  - **Left-Side Navigation Rail**: Persistent brand header, quick destination switcher, and theme toggle.
  - **Side-by-Side Detail View**: Two-column layout with high-res culinary image and macro badges on the left, alongside the dynamic portion scaler, ingredient list, and step-by-step directions on the right.
  - **Max-Width Centering**: Prevents layout stretching on ultrawide monitors.
- ⚡ **Real-Time Cloud Firestore Sync**: Changes to recipes, categories, and favorites immediately sync in real-time across devices.
- ⚖️ **Dynamic Serving Size & Ingredient Scaler**: Adjust serving portions (`-` / `+`) on any recipe, and ingredient quantities instantly recalculate mathematically in real time (e.g. 400g paneer for 2 servings → 800g for 4 servings).
- 🏷️ **Real-Time Dynamic Categories**: Browse dishes by category pills (*Curry, Italian, Breakfast, Healthy, Asian, Dessert*) and create custom categories on-the-fly directly from the app.
- 🔍 **Instant Live Search**: Filter recipes in real-time by recipe title or individual ingredients.
- ❤️ **Persistent Favorites / Bookmarks**: Bookmark recipes with a single tap. Preferences persist across sessions.
- 📝 **Add & Publish Recipes**: Comprehensive recipe submission form with dynamic ingredient row builders, step-by-step instructions, and category assignment.
- 🌓 **Dark & Light Mode**: Curated high-contrast culinary color palette with seamless theme toggle and typography powered by Google Fonts (*Plus Jakarta Sans*).
- 🛡️ **Dual-Mode Architecture (Zero-Crash Demo Mode)**: Runs seamlessly out of the box with an in-memory offline reactive cache if Firebase credentials are not yet configured, so recruiters or collaborators can clone and test without setup friction!

---

## 🏛️ Architecture & State Management

The application follows the **Provider State Pattern** combined with a modular Service/Repository layer:

```
                      ┌─────────────────────────────────────────┐
                      │            Flutter UI Layer             │
                      │  ┌───────────────────┬────────────────┐ │
                      │  │ Mobile (BottomNav)│ Desktop (Rail) │ │
                      │  └───────────────────┴────────────────┘ │
                      └────────────────────┬────────────────────┘
                                           │
                                           ▼
       ┌────────────────────────────────────────────────────────┐
       │             Provider State Management Layer            │
       │  ┌──────────────────┐ ┌────────────────┐ ┌───────────┐ │
       │  │  RecipeProvider  │ │CategoryProvider│ │ThemeProvider│
       │  └────────┬─────────┘ └───────┬────────┘ └───────────┘ │
       └───────────┼───────────────────┼────────────────────────┘
                   │                   │
                   ▼                   ▼
       ┌────────────────────────────────────────────────────────┐
       │               Dual-Mode Firebase Service               │
       │  ┌─────────────────────────┐ ┌──────────────────────┐  │
       │  │ Cloud Firestore (Online)│ │ Offline Demo Cache   │  │
       │  └─────────────────────────┘ └──────────────────────┘  │
       └────────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```text
Recipe/
├── android/                        # Android platform configuration & permissions
├── assets/                         # Application images, icons, and culinary assets
├── ios/                            # iOS Runner configuration
├── windows/                        # Native Windows Desktop runner & CMake config
├── web/                            # Web support configuration
├── lib/
│   ├── models/
│   │   ├── category_model.dart     # Category entity & JSON/Firestore mapping
│   │   ├── ingredient_model.dart   # Ingredient entity with auto-scaling math
│   │   └── recipe_model.dart       # Comprehensive recipe schema
│   ├── providers/
│   │   ├── category_provider.dart  # Category selection & dynamic addition
│   │   ├── recipe_provider.dart    # Live search, favorites, & serving logic
│   │   └── theme_provider.dart     # Dark & Light mode toggle
│   ├── screens/
│   │   ├── add_recipe_screen.dart  # Responsive recipe submission form
│   │   ├── categories_screen.dart  # Responsive categories grid & modal
│   │   ├── favorites_screen.dart   # Responsive saved bookmarks grid
│   │   ├── home_screen.dart        # Responsive home grid & live search
│   │   ├── main_navigation_screen.dart # Adaptive navigation (Bottom Nav vs Rail)
│   │   └── recipe_detail_screen.dart   # Adaptive detail view (Sliver vs Split)
│   ├── services/
│   │   ├── dummy_data.dart         # Curated initial culinary datasets
│   │   └── firebase_service.dart   # Firestore CRUD + graceful offline fallback
│   ├── theme/
│   │   └── app_theme.dart          # Light/dark themes, palettes, and typography
│   ├── utils/
│   │   └── responsive.dart         # Responsive breakpoint helpers & queries
│   ├── widgets/
│   │   ├── category_chip.dart      # Interactive category pill
│   │   ├── recipe_card.dart        # Sleek recipe card with image & stats
│   │   └── serving_counter.dart    # Portions increment/decrement control
│   ├── firebase_options_example.dart # Template for FlutterFire setup
│   └── main.dart                   # Application entry point & MultiProvider
├── test/
│   └── recipe_test.dart            # Unit tests for scaling math & serialization
├── .gitignore                      # Flutter & Dart ignore rules
├── LICENSE                         # MIT License
├── pubspec.yaml                    # Dependencies & Flutter metadata
└── README.md                       # Documentation
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0.0 or higher)
- Android Studio, VS Code, or Antigravity IDE

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/recipe-app.git
cd recipe-app
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App

#### Mobile (Android / iOS)
```bash
flutter run
```

#### Windows Desktop
```bash
flutter run -d windows
```

#### Web (Chrome Browser)
```bash
flutter run -d chrome
```

*The app will automatically launch using the high-fidelity offline sample datasets if Firebase is not yet configured.*

---

## 🔥 Connecting Live Firebase Firestore

1. **Create a Firebase Project** at the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Cloud Firestore** in test mode or production mode.
3. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Run configuration:
   ```bash
   flutterfire configure
   ```
5. In `lib/main.dart`, pass `DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp()`.

---

## 🧪 Running Unit Tests

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
