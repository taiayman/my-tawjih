# Taleb Educational Platform

##  About

Taleb Educational Platform is a Flutter application designed to provide comprehensive educational resources and guidance for students. It offers information about educational pathways, announcements from institutions, job and competition opportunities, and a support chat system for direct communication with administrators. 

## Features

- **Education Pathways:** Explore detailed information about various educational pathways, including specializations and universities offering those programs.
- **Announcements:** Stay up-to-date with the latest announcements from educational institutions. Filter announcements based on education level (Bac, Bac+2, Bac+3, Other).
- **Mostajadat (Updates):**  Discover a curated list of updates and opportunities, categorized as either jobs or guidance. Mostajadat can be customized with rich text, images, and links.
- **Admin Dashboard:**  Administrators can manage the content of the app, including news, announcements, Mostajadat, and interact with users via a chat interface.
- **Push Notifications:**  Receive important updates and announcements directly to your device.
- **Multilingual Support:** The app supports Arabic, English, and French.
- **Support Chat:**  Contact the platform administrators for assistance and guidance directly through the app.

## Project Structure

The project follows a typical Flutter structure with the following key directories and files:

- **lib:** Contains the core Flutter application code.
  - **screens:** Houses all the UI screens (e.g., `home_screen.dart`, `signin_screen.dart`, `admin_dashboard.dart`).
  - **models:** Defines the data models used in the app (e.g., `announcement_model.dart`, `education_pathway.dart`).
  - **providers:** Implements Riverpod providers for state management and data access (e.g., `auth_provider.dart`, `mostajadat_provider.dart`).
  - **services:**  Provides backend services like authentication, Firestore interaction, notifications (e.g., `auth_service.dart`, `firestore_service.dart`).
  - **widgets:** Contains reusable UI components (e.g., `announcement_card.dart`, `custom_bottom_navigation.dart`).
- **assets:** Stores assets like images, animations, and translation files.
  - **translations:** Holds the JSON files for localization (e.g., `ar.json`, `en.json`, `fr.json`). 
- **pubspec.yaml:**  Lists the project dependencies and metadata.

## Getting Started

1. **Clone the repository:** `git clone https://github.com/your-username/taleb-edu-platform.git`
2. **Install dependencies:** `flutter pub get`
3. **Set up Firebase:**
    - Create a Firebase project.
    - Configure Firebase for Flutter ([https://firebase.flutter.dev/docs/overview](https://firebase.flutter.dev/docs/overview)).
    - Add the necessary Firebase configuration files (e.g., `google-services.json` for Android, `GoogleService-Info.plist` for iOS) to your project.
4. **Configure OneSignal:**
    - Create a OneSignal account.
    - Set up a OneSignal app.
    - Replace the OneSignal App ID placeholder in `main.dart`.
5. **Run the app:** `flutter run`

## Technologies Used

- **Flutter:**  Cross-platform mobile app development framework.
- **Riverpod:** State management library for Flutter.
- **Firebase:**  Backend services (authentication, database, storage, cloud functions, messaging).
- **OneSignal:** Push notification service.
- **Easy Localization:**  Package for internationalization and localization.

## Future Improvements

- **Enhanced Search:** Improve the search functionality across all sections of the app.
- **User Profiles:**  Allow users to create profiles and save their preferences.
- **Gamification:** Introduce gamification elements (points, badges) to encourage user engagement.
- **Content Moderation:** Implement tools for administrators to moderate user-generated content.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. 