# Ingredio

Ingredio is a Flutter application designed to help users find recipes based on the ingredients they already have. The app provides a focused pantry workflow, recipe discovery, saved favorites, and a simple profile experience.

## Features

- **Ingredient Selection**: Users can select ingredients they have from a comprehensive list.
- **Recipe Search**: The app fetches recipes based on the selected ingredients.
- **Recipe Details**: Detailed view of each recipe including ingredients, instructions, and category.
- **Favorites**: Users can mark recipes as favorites for quick access.
- **Profile and Onboarding**: Users register with a name before using the app and can manage account actions from the profile screen.
- **Offline Support**: The app caches data for offline access.
- **Share Recipes**: Users can share recipes with others.
- **Connectivity Check**: The app checks for internet connectivity and handles offline scenarios gracefully.

## Screenshots

### Design System

<img src="./assets/images/culinary_intelligence.png" alt="Culinary Intelligence design system" width="720">
<img src="./assets/images/design_palette.png" alt="Design Palette" width="720">

### App Screens

<table>
  <tr>
    <td align="center"><strong>Register</strong></td>
    <td align="center"><strong>Discover</strong></td>
    <td align="center"><strong>Pantry</strong></td>
    <td align="center"><strong>Recipe Detail</strong></td>
    <td align="center"><strong>Profile</strong></td>
  </tr>
  <tr>
    <td><img src="./assets/images/register.png" alt="Register screen" width="220"></td>
    <td><img src="./assets/images/discover.png" alt="Discover screen" width="220"></td>
    <td><img src="./assets/images/pantry.png" alt="Pantry screen" width="220"></td>
    <td><img src="./assets/images/receipt_detail.png" alt="Recipe detail screen" width="220"></td>
    <td><img src="./assets/images/profile.png" alt="Profile screen" width="220"></td>
  </tr>
</table>

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/soffffises/Ingredio.git
   ```
2. Navigate to the project directory:
   ```sh
   cd Ingredio
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```

### Running the App

To run the app on an emulator or physical device, use the following command:
```sh
flutter run
```

### Building for Release

To build the app for release, use the following command:
```sh
flutter build apk
```

## Project Structure

- **lib**: Contains the main Dart code for the application.
  - **presentation**: UI components and screens.
  - **domain**: Business logic and use cases.
  - **data**: Data sources and repositories.
  - **core**: Core utilities and constants.
  - **di**: Dependency injection setup.

## Technologies and Libraries

- **Architecture**: The project follows a clean architecture approach, separating the application into presentation, domain, and data layers.
- **State Management**: The app uses `flutter_riverpod` for state management.
- **Dependency Injection**: `get_it` is used for dependency injection.
- **Networking**: `dio` is used for making network requests.
- **Local Storage**: `hive` and `hive_flutter` are used for local storage.
- **Image Loading**: `cached_network_image` is used for efficient image loading and caching.
- **Connectivity**: `connectivity_plus` is used to check internet connectivity.
- **Sharing**: `share_plus` is used for sharing recipes.
- **URL Launching**: `url_launcher` is used for launching URLs.


The repository must contain tests in the test/ folder, all passing when running flutter
test:
– Unit tests covering at least one model class (fromJson/toJson), all validator functions, and at least one provider or service method.
– At least one widget test that renders a widget and verifies its content using
WidgetTester.
